#!/usr/bin/env python3
"""
WordMate Test Report Generation Script

This script generates comprehensive test reports from Robot Framework
test results, combining multiple output files and creating enhanced
HTML reports with analytics and visualizations.

Usage:
    python scripts/generate_report.py --input-dir reports/ --output-dir final-reports/
    python scripts/generate_report.py --environment dev --report-type nightly
    python scripts/generate_report.py --open
"""

import os
import sys
import argparse
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from datetime import datetime, timedelta
import shutil
import webbrowser
from typing import Dict, List, Optional, Any
import base64

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

try:
    import matplotlib

    matplotlib.use("Agg")  # Use non-interactive backend
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    from matplotlib.patches import Wedge

    MATPLOTLIB_AVAILABLE = True
except ImportError:
    MATPLOTLIB_AVAILABLE = False
    print("Warning: matplotlib not available. Charts will not be generated.")

try:
    from jinja2 import Template, Environment, FileSystemLoader

    JINJA2_AVAILABLE = True
except ImportError:
    JINJA2_AVAILABLE = False
    print("Warning: jinja2 not available. Using basic HTML generation.")


class WordMateReportGenerator:
    """Enhanced test report generator for WordMate test results"""

    def __init__(self):
        self.project_root = project_root
        self.templates_dir = self.project_root / "templates" / "reports"
        self.charts_dir = Path("charts")

        # Report data structure
        self.report_data = {
            "meta": {
                "generated_at": datetime.now().isoformat(),
                "generator_version": "1.0.0",
                "project": "WordMate QA Automation",
            },
            "summary": {
                "total_tests": 0,
                "passed_tests": 0,
                "failed_tests": 0,
                "skipped_tests": 0,
                "error_tests": 0,
                "success_rate": 0.0,
                "execution_time_seconds": 0,
                "environments": [],
                "browsers": [],
                "test_suites": [],
            },
            "details": {
                "test_suites": [],
                "failed_tests": [],
                "performance_metrics": {},
                "trends": [],
                "coverage": {},
            },
            "charts": [],
            "recommendations": [],
        }

        # Initialize Jinja2 environment if available
        if JINJA2_AVAILABLE:
            try:
                self.jinja_env = Environment(
                    loader=FileSystemLoader(str(self.templates_dir))
                )
            except Exception:
                self.jinja_env = None
        else:
            self.jinja_env = None

    def parse_robot_output_files(self, input_dir: Path) -> None:
        """Parse Robot Framework output XML files"""
        xml_files = list(input_dir.rglob("*.xml"))

        if not xml_files:
            print(f"No XML files found in {input_dir}")
            return

        print(f"Processing {len(xml_files)} XML files...")

        for xml_file in xml_files:
            try:
                self._parse_single_xml_file(xml_file)
            except Exception as e:
                print(f"Error parsing {xml_file}: {e}")
                continue

        self._calculate_summary_statistics()

    def _parse_single_xml_file(self, xml_file: Path) -> None:
        """Parse single Robot Framework XML file"""
        try:
            tree = ET.parse(xml_file)
            root = tree.getroot()

            # Extract suite information
            suite_info = self._extract_suite_info(root, xml_file)
            if suite_info:
                self.report_data["details"]["test_suites"].append(suite_info)

            # Extract test statistics
            self._extract_test_statistics(root)

            # Extract failed tests
            self._extract_failed_tests(root, xml_file)

            # Extract performance metrics
            self._extract_performance_metrics(root, xml_file)

        except ET.ParseError as e:
            print(f"XML parsing error in {xml_file}: {e}")
        except Exception as e:
            print(f"Unexpected error parsing {xml_file}: {e}")

    def _extract_suite_info(self, root: ET.Element, xml_file: Path) -> Dict[str, Any]:
        """Extract test suite information"""
        suite_element = root.find(".//suite")
        if suite_element is None:
            return None

        suite_info = {
            "name": suite_element.get("name", "Unknown"),
            "source": suite_element.get("source", str(xml_file)),
            "file": str(xml_file),
            "tests": [],
            "statistics": {"total": 0, "passed": 0, "failed": 0, "skipped": 0},
            "execution_time": 0,
            "start_time": None,
            "end_time": None,
        }

        # Extract suite timing
        status_element = suite_element.find(".//status")
        if status_element is not None:
            suite_info["start_time"] = status_element.get("starttime")
            suite_info["end_time"] = status_element.get("endtime")
            elapsed = status_element.get("elapsed")
            if elapsed:
                suite_info["execution_time"] = (
                    int(elapsed) / 1000.0
                )  # Convert to seconds

        # Extract individual tests
        for test_element in suite_element.findall(".//test"):
            test_info = self._extract_test_info(test_element)
            if test_info:
                suite_info["tests"].append(test_info)
                suite_info["statistics"]["total"] += 1
                if test_info["status"] == "PASS":
                    suite_info["statistics"]["passed"] += 1
                elif test_info["status"] == "FAIL":
                    suite_info["statistics"]["failed"] += 1
                else:
                    suite_info["statistics"]["skipped"] += 1

        return suite_info

    def _extract_test_info(self, test_element: ET.Element) -> Dict[str, Any]:
        """Extract individual test information"""
        test_info = {
            "name": test_element.get("name", "Unknown"),
            "status": "UNKNOWN",
            "message": "",
            "tags": [],
            "keywords": [],
            "execution_time": 0,
            "start_time": None,
            "end_time": None,
        }

        # Extract test status
        status_element = test_element.find(".//status")
        if status_element is not None:
            test_info["status"] = status_element.get("status", "UNKNOWN")
            test_info["message"] = status_element.text or ""
            test_info["start_time"] = status_element.get("starttime")
            test_info["end_time"] = status_element.get("endtime")
            elapsed = status_element.get("elapsed")
            if elapsed:
                test_info["execution_time"] = int(elapsed) / 1000.0

        # Extract tags
        tags_element = test_element.find(".//tags")
        if tags_element is not None:
            for tag in tags_element.findall("tag"):
                test_info["tags"].append(tag.text)

        # Extract keywords (simplified)
        for kw_element in test_element.findall(".//kw"):
            kw_name = kw_element.get("name", "Unknown")
            kw_status = kw_element.find(".//status")
            kw_status_text = (
                kw_status.get("status") if kw_status is not None else "UNKNOWN"
            )
            test_info["keywords"].append({"name": kw_name, "status": kw_status_text})

        return test_info

    def _extract_test_statistics(self, root: ET.Element) -> None:
        """Extract overall test statistics"""
        stats_element = root.find(".//statistics/total/stat")
        if stats_element is not None:
            passed = int(stats_element.get("pass", 0))
            failed = int(stats_element.get("fail", 0))

            self.report_data["summary"]["passed_tests"] += passed
            self.report_data["summary"]["failed_tests"] += failed
            self.report_data["summary"]["total_tests"] += passed + failed

    def _extract_failed_tests(self, root: ET.Element, xml_file: Path) -> None:
        """Extract information about failed tests"""
        for test_element in root.findall(".//test"):
            status_element = test_element.find(".//status")
            if status_element is not None and status_element.get("status") == "FAIL":
                failed_test = {
                    "name": test_element.get("name", "Unknown"),
                    "suite": root.find(".//suite").get("name", "Unknown"),
                    "message": status_element.text or "No error message",
                    "file": str(xml_file),
                    "tags": [],
                }

                # Extract tags
                tags_element = test_element.find(".//tags")
                if tags_element is not None:
                    for tag in tags_element.findall("tag"):
                        failed_test["tags"].append(tag.text)

                self.report_data["details"]["failed_tests"].append(failed_test)

    def _extract_performance_metrics(self, root: ET.Element, xml_file: Path) -> None:
        """Extract performance metrics from test results"""
        suite_element = root.find(".//suite")
        if suite_element is not None:
            status_element = suite_element.find(".//status")
            if status_element is not None:
                elapsed = status_element.get("elapsed")
                if elapsed:
                    execution_time = int(elapsed) / 1000.0
                    self.report_data["summary"][
                        "execution_time_seconds"
                    ] += execution_time

                    # Store per-file metrics
                    file_key = str(xml_file.name)
                    self.report_data["details"]["performance_metrics"][file_key] = {
                        "execution_time": execution_time,
                        "test_count": len(list(root.findall(".//test"))),
                    }

    def _calculate_summary_statistics(self) -> None:
        """Calculate summary statistics"""
        total = self.report_data["summary"]["total_tests"]
        passed = self.report_data["summary"]["passed_tests"]

        if total > 0:
            self.report_data["summary"]["success_rate"] = (passed / total) * 100

        # Extract unique environments and browsers from test data
        environments = set()
        browsers = set()
        test_suites = set()

        for suite in self.report_data["details"]["test_suites"]:
            test_suites.add(suite["name"])
            for test in suite["tests"]:
                for tag in test["tags"]:
                    if tag in ["dev", "production", "staging"]:
                        environments.add(tag)
                    elif tag in ["chrome", "firefox", "edge", "safari"]:
                        browsers.add(tag)

        self.report_data["summary"]["environments"] = list(environments)
        self.report_data["summary"]["browsers"] = list(browsers)
        self.report_data["summary"]["test_suites"] = list(test_suites)

    def generate_charts(self, output_dir: Path) -> None:
        """Generate charts and visualizations"""
        if not MATPLOTLIB_AVAILABLE:
            print("Skipping chart generation - matplotlib not available")
            return

        charts_output_dir = output_dir / self.charts_dir
        charts_output_dir.mkdir(parents=True, exist_ok=True)

        # Generate pie chart for test results
        self._generate_test_results_pie_chart(charts_output_dir)

        # Generate execution time chart
        self._generate_execution_time_chart(charts_output_dir)

        # Generate test suite comparison chart
        self._generate_test_suite_chart(charts_output_dir)

        print(f"Charts generated in {charts_output_dir}")

    def _generate_test_results_pie_chart(self, charts_dir: Path) -> None:
        """Generate pie chart for test results"""
        try:
            passed = self.report_data["summary"]["passed_tests"]
            failed = self.report_data["summary"]["failed_tests"]

            if passed == 0 and failed == 0:
                return

            fig, ax = plt.subplots(figsize=(8, 6))

            labels = []
            sizes = []
            colors = []

            if passed > 0:
                labels.append(f"Passed ({passed})")
                sizes.append(passed)
                colors.append("#28a745")

            if failed > 0:
                labels.append(f"Failed ({failed})")
                sizes.append(failed)
                colors.append("#dc3545")

            ax.pie(
                sizes, labels=labels, colors=colors, autopct="%1.1f%%", startangle=90
            )
            ax.set_title("Test Results Distribution", fontsize=16, fontweight="bold")

            plt.tight_layout()
            chart_path = charts_dir / "test_results_pie.png"
            plt.savefig(chart_path, dpi=150, bbox_inches="tight")
            plt.close()

            self.report_data["charts"].append(
                {
                    "name": "Test Results Distribution",
                    "file": str(chart_path.name),
                    "type": "pie",
                }
            )

        except Exception as e:
            print(f"Error generating pie chart: {e}")

    def _generate_execution_time_chart(self, charts_dir: Path) -> None:
        """Generate execution time chart"""
        try:
            performance_data = self.report_data["details"]["performance_metrics"]

            if not performance_data:
                return

            files = list(performance_data.keys())
            times = [performance_data[f]["execution_time"] for f in files]

            fig, ax = plt.subplots(figsize=(12, 6))

            bars = ax.bar(range(len(files)), times, color="#007bff", alpha=0.7)
            ax.set_xlabel("Test Files")
            ax.set_ylabel("Execution Time (seconds)")
            ax.set_title("Execution Time by Test File", fontsize=16, fontweight="bold")
            ax.set_xticks(range(len(files)))
            ax.set_xticklabels(
                [f[:20] + "..." if len(f) > 20 else f for f in files],
                rotation=45,
                ha="right",
            )

            # Add value labels on bars
            for bar, time in zip(bars, times):
                height = bar.get_height()
                ax.text(
                    bar.get_x() + bar.get_width() / 2.0,
                    height + 0.1,
                    f"{time:.1f}s",
                    ha="center",
                    va="bottom",
                )

            plt.tight_layout()
            chart_path = charts_dir / "execution_time_chart.png"
            plt.savefig(chart_path, dpi=150, bbox_inches="tight")
            plt.close()

            self.report_data["charts"].append(
                {
                    "name": "Execution Time by Test File",
                    "file": str(chart_path.name),
                    "type": "bar",
                }
            )

        except Exception as e:
            print(f"Error generating execution time chart: {e}")

    def _generate_test_suite_chart(self, charts_dir: Path) -> None:
        """Generate test suite comparison chart"""
        try:
            suites = self.report_data["details"]["test_suites"]

            if not suites:
                return

            suite_names = [
                suite["name"][:15] + "..." if len(suite["name"]) > 15 else suite["name"]
                for suite in suites
            ]
            passed_counts = [suite["statistics"]["passed"] for suite in suites]
            failed_counts = [suite["statistics"]["failed"] for suite in suites]

            fig, ax = plt.subplots(figsize=(12, 8))

            x = range(len(suite_names))
            width = 0.35

            bars1 = ax.bar(
                [i - width / 2 for i in x],
                passed_counts,
                width,
                label="Passed",
                color="#28a745",
                alpha=0.8,
            )
            bars2 = ax.bar(
                [i + width / 2 for i in x],
                failed_counts,
                width,
                label="Failed",
                color="#dc3545",
                alpha=0.8,
            )

            ax.set_xlabel("Test Suites")
            ax.set_ylabel("Number of Tests")
            ax.set_title("Test Results by Suite", fontsize=16, fontweight="bold")
            ax.set_xticks(x)
            ax.set_xticklabels(suite_names, rotation=45, ha="right")
            ax.legend()

            # Add value labels on bars
            for bars in [bars1, bars2]:
                for bar in bars:
                    height = bar.get_height()
                    if height > 0:
                        ax.text(
                            bar.get_x() + bar.get_width() / 2.0,
                            height + 0.1,
                            f"{int(height)}",
                            ha="center",
                            va="bottom",
                        )

            plt.tight_layout()
            chart_path = charts_dir / "test_suite_comparison.png"
            plt.savefig(chart_path, dpi=150, bbox_inches="tight")
            plt.close()

            self.report_data["charts"].append(
                {
                    "name": "Test Results by Suite",
                    "file": str(chart_path.name),
                    "type": "bar",
                }
            )

        except Exception as e:
            print(f"Error generating test suite chart: {e}")

    def generate_recommendations(self) -> None:
        """Generate recommendations based on test results"""
        recommendations = []

        # Success rate recommendations
        success_rate = self.report_data["summary"]["success_rate"]
        if success_rate < 70:
            recommendations.append(
                {
                    "type": "critical",
                    "title": "Low Success Rate",
                    "message": f"Test success rate is {success_rate:.1f}%. Investigate failed tests immediately.",
                    "action": "Review failed tests and fix underlying issues",
                }
            )
        elif success_rate < 90:
            recommendations.append(
                {
                    "type": "warning",
                    "title": "Moderate Success Rate",
                    "message": f"Test success rate is {success_rate:.1f}%. Consider improving test stability.",
                    "action": "Analyze flaky tests and improve test reliability",
                }
            )

        # Performance recommendations
        total_time = self.report_data["summary"]["execution_time_seconds"]
        if total_time > 3600:  # More than 1 hour
            recommendations.append(
                {
                    "type": "warning",
                    "title": "Long Execution Time",
                    "message": f"Total execution time is {total_time/60:.1f} minutes. Consider optimization.",
                    "action": "Parallelize tests or optimize slow test cases",
                }
            )

        # Failed test recommendations
        failed_count = len(self.report_data["details"]["failed_tests"])
        if failed_count > 10:
            recommendations.append(
                {
                    "type": "warning",
                    "title": "High Number of Failed Tests",
                    "message": f"{failed_count} tests failed. Focus on fixing critical failures first.",
                    "action": "Prioritize fixes based on test importance and failure frequency",
                }
            )

        # Coverage recommendations
        total_tests = self.report_data["summary"]["total_tests"]
        if total_tests < 50:
            recommendations.append(
                {
                    "type": "info",
                    "title": "Low Test Coverage",
                    "message": f"Only {total_tests} tests executed. Consider expanding test coverage.",
                    "action": "Add more comprehensive test cases for better coverage",
                }
            )

        self.report_data["recommendations"] = recommendations

    def generate_html_report(
        self, output_dir: Path, environment: str = None, report_type: str = "standard"
    ) -> Path:
        """Generate comprehensive HTML report"""
        # Generate recommendations
        self.generate_recommendations()

        # Prepare template data
        template_data = {
            "report": self.report_data,
            "environment": environment or "unknown",
            "report_type": report_type,
            "charts_dir": str(self.charts_dir),
        }

        # Generate HTML content
        if self.jinja_env and self._template_exists("report_template.html"):
            html_content = self._generate_html_with_template(template_data)
        else:
            html_content = self._generate_html_fallback(template_data)

        # Write HTML file
        report_file = output_dir / f"wordmate_test_report_{report_type}.html"
        with open(report_file, "w", encoding="utf-8") as f:
            f.write(html_content)

        print(f"HTML report generated: {report_file}")
        return report_file

    def _template_exists(self, template_name: str) -> bool:
        """Check if template file exists"""
        try:
            self.jinja_env.get_template(template_name)
            return True
        except Exception:
            return False

    def _generate_html_with_template(self, template_data: Dict) -> str:
        """Generate HTML using Jinja2 template"""
        try:
            template = self.jinja_env.get_template("report_template.html")
            return template.render(**template_data)
        except Exception as e:
            print(f"Template rendering error: {e}")
            return self._generate_html_fallback(template_data)

    def _generate_html_fallback(self, template_data: Dict) -> str:
        """Generate HTML using fallback method"""
        report = template_data["report"]
        environment = template_data["environment"]
        report_type = template_data["report_type"]

        html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WordMate Test Report - {report_type.title()}</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f8f9fa; }}
        .container {{ max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        .header {{ background: linear-gradient(135deg, #007bff, #0056b3); color: white; padding: 30px; border-radius: 8px 8px 0 0; }}
        .header h1 {{ margin: 0; font-size: 2.5em; }}
        .header .meta {{ margin-top: 10px; opacity: 0.9; }}
        .summary {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 30px; }}
        .metric {{ background: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #007bff; }}
        .metric.success {{ border-color: #28a745; }}
        .metric.danger {{ border-color: #dc3545; }}
        .metric-value {{ font-size: 2em; font-weight: bold; margin-bottom: 5px; }}
        .metric-label {{ color: #6c757d; text-transform: uppercase; font-size: 0.8em; letter-spacing: 1px; }}
        .section {{ padding: 30px; border-top: 1px solid #dee2e6; }}
        .section h2 {{ color: #343a40; margin-bottom: 20px; }}
        .charts {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 20px; }}
        .chart {{ text-align: center; background: #f8f9fa; padding: 20px; border-radius: 8px; }}
        .chart img {{ max-width: 100%; height: auto; }}
        .failed-tests {{ background: #fff5f5; border: 1px solid #fed7d7; border-radius: 8px; padding: 20px; }}
        .failed-test {{ margin-bottom: 15px; padding: 15px; background: white; border-radius: 4px; border-left: 4px solid #dc3545; }}
        .recommendations {{ background: #f0f9ff; border: 1px solid #bfdbfe; border-radius: 8px; padding: 20px; }}
        .recommendation {{ margin-bottom: 15px; padding: 15px; background: white; border-radius: 4px; }}
        .recommendation.critical {{ border-left: 4px solid #dc3545; }}
        .recommendation.warning {{ border-left: 4px solid #ffc107; }}
        .recommendation.info {{ border-left: 4px solid #17a2b8; }}
        .test-suites {{ overflow-x: auto; }}
        .test-suites table {{ width: 100%; border-collapse: collapse; }}
        .test-suites th, .test-suites td {{ padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6; }}
        .test-suites th {{ background: #f8f9fa; font-weight: 600; }}
        .status-pass {{ color: #28a745; font-weight: bold; }}
        .status-fail {{ color: #dc3545; font-weight: bold; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>WordMate Test Report</h1>
            <div class="meta">
                <div>Environment: {environment.title()} | Type: {report_type.title()}</div>
                <div>Generated: {report['meta']['generated_at']}</div>
            </div>
        </div>
        
        <div class="summary">
            <div class="metric">
                <div class="metric-value">{report['summary']['total_tests']}</div>
                <div class="metric-label">Total Tests</div>
            </div>
            <div class="metric success">
                <div class="metric-value">{report['summary']['passed_tests']}</div>
                <div class="metric-label">Passed</div>
            </div>
            <div class="metric danger">
                <div class="metric-value">{report['summary']['failed_tests']}</div>
                <div class="metric-label">Failed</div>
            </div>
            <div class="metric">
                <div class="metric-value">{report['summary']['success_rate']:.1f}%</div>
                <div class="metric-label">Success Rate</div>
            </div>
            <div class="metric">
                <div class="metric-value">{report['summary']['execution_time_seconds']:.1f}s</div>
                <div class="metric-label">Execution Time</div>
            </div>
        </div>
"""

        # Add charts section if charts exist
        if report["charts"]:
            html += f"""
        <div class="section">
            <h2>📊 Test Analytics</h2>
            <div class="charts">
"""
            for chart in report["charts"]:
                html += f"""
                <div class="chart">
                    <h3>{chart['name']}</h3>
                    <img src="{template_data['charts_dir']}/{chart['file']}" alt="{chart['name']}">
                </div>
"""
            html += """
            </div>
        </div>
"""

        # Add test suites section
        if report["details"]["test_suites"]:
            html += """
        <div class="section">
            <h2>📋 Test Suites</h2>
            <div class="test-suites">
                <table>
                    <thead>
                        <tr>
                            <th>Suite Name</th>
                            <th>Total Tests</th>
                            <th>Passed</th>
                            <th>Failed</th>
                            <th>Success Rate</th>
                            <th>Execution Time</th>
                        </tr>
                    </thead>
                    <tbody>
"""
            for suite in report["details"]["test_suites"]:
                total = suite["statistics"]["total"]
                passed = suite["statistics"]["passed"]
                success_rate = (passed / total * 100) if total > 0 else 0

                html += f"""
                        <tr>
                            <td>{suite['name']}</td>
                            <td>{total}</td>
                            <td class="status-pass">{passed}</td>
                            <td class="status-fail">{suite['statistics']['failed']}</td>
                            <td>{success_rate:.1f}%</td>
                            <td>{suite['execution_time']:.1f}s</td>
                        </tr>
"""
            html += """
                    </tbody>
                </table>
            </div>
        </div>
"""

        # Add failed tests section
        if report["details"]["failed_tests"]:
            html += """
        <div class="section">
            <h2>❌ Failed Tests</h2>
            <div class="failed-tests">
"""
            for failed_test in report["details"]["failed_tests"]:
                html += f"""
                <div class="failed-test">
                    <h4>{failed_test['name']}</h4>
                    <p><strong>Suite:</strong> {failed_test['suite']}</p>
                    <p><strong>Error:</strong> {failed_test['message']}</p>
                    <p><strong>Tags:</strong> {', '.join(failed_test['tags']) if failed_test['tags'] else 'None'}</p>
                </div>
"""
            html += """
            </div>
        </div>
"""

        # Add recommendations section
        if report["recommendations"]:
            html += """
        <div class="section">
            <h2>💡 Recommendations</h2>
            <div class="recommendations">
"""
            for rec in report["recommendations"]:
                html += f"""
                <div class="recommendation {rec['type']}">
                    <h4>{rec['title']}</h4>
                    <p>{rec['message']}</p>
                    <p><strong>Action:</strong> {rec['action']}</p>
                </div>
"""
            html += """
            </div>
        </div>
"""

        html += """
    </div>
</body>
</html>
"""
        return html

    def copy_assets(self, output_dir: Path) -> None:
        """Copy static assets to output directory"""
        # Copy charts if they exist
        charts_src = output_dir / self.charts_dir
        if charts_src.exists():
            print(f"Charts available in {charts_src}")

    def generate_json_report(self, output_dir: Path) -> Path:
        """Generate JSON report for programmatic access"""
        json_file = output_dir / "test_results.json"
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(self.report_data, f, indent=2, ensure_ascii=False)

        print(f"JSON report generated: {json_file}")
        return json_file

    def generate_complete_report(
        self,
        input_dir: Path,
        output_dir: Path,
        environment: str = None,
        report_type: str = "standard",
        open_report: bool = False,
    ) -> Dict[str, Path]:
        """Generate complete test report with all components"""
        print(
            f"Generating {report_type} report for {environment or 'unknown'} environment..."
        )

        # Create output directory
        output_dir.mkdir(parents=True, exist_ok=True)

        # Parse test results
        self.parse_robot_output_files(input_dir)

        # Generate charts
        self.generate_charts(output_dir)

        # Generate reports
        html_report = self.generate_html_report(output_dir, environment, report_type)
        json_report = self.generate_json_report(output_dir)

        # Copy assets
        self.copy_assets(output_dir)

        # Open report if requested
        if open_report:
            try:
                webbrowser.open(f"file://{html_report.absolute()}")
            except Exception as e:
                print(f"Could not open report automatically: {e}")

        report_files = {"html": html_report, "json": json_report}

        print(f"\n📊 Report generation complete!")
        print(f"   HTML Report: {html_report}")
        print(f"   JSON Report: {json_report}")
        print(f"   Success Rate: {self.report_data['summary']['success_rate']:.1f}%")
        print(f"   Total Tests: {self.report_data['summary']['total_tests']}")

        return report_files


def create_argument_parser():
    """Create command line argument parser"""
    parser = argparse.ArgumentParser(
        description="WordMate Test Report Generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --input-dir reports/ --output-dir final-reports/
  %(prog)s --environment dev --report-type nightly
  %(prog)s --input-dir reports/ --open
        """,
    )

    parser.add_argument(
        "--input-dir",
        type=Path,
        default=Path("reports"),
        help="Directory containing Robot Framework output files",
    )

    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("final-reports"),
        help="Directory for generated reports",
    )

    parser.add_argument("--environment", default="dev", help="Test environment name")

    parser.add_argument(
        "--report-type",
        default="standard",
        choices=["standard", "nightly", "regression", "smoke"],
        help="Type of report to generate",
    )

    parser.add_argument(
        "--open",
        action="store_true",
        help="Open HTML report in browser after generation",
    )

    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")

    return parser


def main():
    """Main entry point"""
    parser = create_argument_parser()
    args = parser.parse_args()

    try:
        generator = WordMateReportGenerator()

        # Validate input directory
        if not args.input_dir.exists():
            print(f"Error: Input directory {args.input_dir} does not exist")
            return 1

        # Generate report
        report_files = generator.generate_complete_report(
            input_dir=args.input_dir,
            output_dir=args.output_dir,
            environment=args.environment,
            report_type=args.report_type,
            open_report=args.open,
        )

        return 0

    except Exception as e:
        print(f"Error generating report: {e}")
        if args.verbose:
            import traceback

            traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
