from setuptools import find_packages, setup

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [
        line.strip() for line in fh if line.strip() and not line.startswith("#")
    ]

setup(
    name="robot-framework-qa-api-automation",
    version="1.0.0",
    author="WordMate QA Team",
    author_email="qa@wordmate.es",
    description="Robot Framework automation suite for WordMate application testing",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/wordmate/robot-framework-qa-api-automation",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Software Development :: Testing",
        "Topic :: Software Development :: Quality Assurance",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    extras_require={
        "dev": [
            "black==23.12.1",
            "flake8==7.1.1",
            "isort==5.13.2",
            "pre-commit==3.8.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "wordmate-tests=scripts.run_tests:main",
        ],
    },
)
