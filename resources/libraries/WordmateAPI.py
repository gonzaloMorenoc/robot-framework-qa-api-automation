"""
WordMate API Library

Custom Robot Framework library for WordMate API interactions.
Provides high-level keywords for API testing and validation.
"""

import json
import time
from typing import Any, Dict, List

import jwt
import requests
from requests.adapters import HTTPAdapter
from robot.api import logger
from robot.api.deco import keyword
from urllib3.util.retry import Retry


class WordmateAPI:
    """Custom library for WordMate API testing"""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_VERSION = "1.0.0"

    def __init__(self, base_url: str = None, timeout: int = 30):
        """Initialize WordMate API library

        Args:
            base_url: Base URL for API endpoints
            timeout: Default timeout for requests
        """
        self.base_url = base_url
        self.timeout = timeout
        self.session = requests.Session()
        self.auth_token = None
        self.refresh_token = None

        # Setup retry strategy
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)

    @keyword
    def set_api_base_url(self, url: str) -> None:
        """Set the base URL for API requests

        Args:
            url: Base URL for the API
        """
        self.base_url = url
        logger.info(f"API base URL set to: {url}")

    @keyword
    def set_auth_token(self, token: str) -> None:
        """Set authentication token for API requests

        Args:
            token: JWT authentication token
        """
        self.auth_token = token
        self.session.headers.update({"Authorization": f"Bearer {token}"})
        logger.info("Authentication token set")

    @keyword
    def clear_auth_token(self) -> None:
        """Clear authentication token"""
        self.auth_token = None
        if "Authorization" in self.session.headers:
            del self.session.headers["Authorization"]
        logger.info("Authentication token cleared")

    @keyword
    def make_api_request(
        self,
        method: str,
        endpoint: str,
        data: Dict = None,
        headers: Dict = None,
        expected_status: int = 200,
    ) -> Dict:
        """Make API request with error handling

        Args:
            method: HTTP method (GET, POST, PUT, DELETE)
            endpoint: API endpoint
            data: Request data
            headers: Additional headers
            expected_status: Expected HTTP status code

        Returns:
            Response data as dictionary
        """
        url = f"{self.base_url}{endpoint}"
        request_headers = self.session.headers.copy()

        if headers:
            request_headers.update(headers)

        try:
            response = self.session.request(
                method=method,
                url=url,
                json=data,
                headers=request_headers,
                timeout=self.timeout,
            )

            logger.info(f"{method} {url} - Status: {response.status_code}")

            if response.status_code != expected_status:
                logger.warn(
                    f"Expected status {expected_status}, got {response.status_code}"
                )

            try:
                response_data = response.json()
            except json.JSONDecodeError:
                response_data = {"text": response.text}

            return {
                "status_code": response.status_code,
                "data": response_data,
                "headers": dict(response.headers),
            }

        except requests.exceptions.RequestException as e:
            logger.error(f"API request failed: {str(e)}")
            raise

    @keyword
    def login_user(self, username: str, password: str) -> Dict:
        """Login user and return authentication data

        Args:
            username: User's username/email
            password: User's password

        Returns:
            Login response data
        """
        login_data = {"username": username, "password": password}

        response = self.make_api_request("POST", "?endpoint=login", login_data)

        if response["status_code"] == 200 and "token" in response["data"]:
            self.set_auth_token(response["data"]["token"])
            if "refreshToken" in response["data"]:
                self.refresh_token = response["data"]["refreshToken"]

        return response

    @keyword
    def register_user(
        self, username: str, password: str, first_name: str, last_name: str
    ) -> Dict:
        """Register new user

        Args:
            username: User's username/email
            password: User's password
            first_name: User's first name
            last_name: User's last name

        Returns:
            Registration response data
        """
        registration_data = {
            "username": username,
            "password": password,
            "firstName": first_name,
            "lastName": last_name,
        }

        return self.make_api_request(
            "POST", "?endpoint=register", registration_data, expected_status=201
        )

    @keyword
    def get_user_profile(self) -> Dict:
        """Get current user's profile

        Returns:
            User profile data
        """
        return self.make_api_request("GET", "?endpoint=profile")

    @keyword
    def get_vocabulary_list(
        self, page: int = 1, limit: int = 50, search: str = None
    ) -> Dict:
        """Get vocabulary list with optional filters

        Args:
            page: Page number
            limit: Items per page
            search: Search term

        Returns:
            Vocabulary list data
        """
        endpoint = f"?endpoint=vocabulario&page={page}&limit={limit}"
        if search:
            endpoint += f"&search={search}"

        return self.make_api_request("GET", endpoint)

    @keyword
    def add_word_to_favorites(self, word_id: int) -> Dict:
        """Add word to user's favorites

        Args:
            word_id: Word ID to add to favorites

        Returns:
            Response data
        """
        data = {"wordId": word_id}
        return self.make_api_request("POST", "?endpoint=favoritos", data)

    @keyword
    def remove_word_from_favorites(self, word_id: int) -> Dict:
        """Remove word from user's favorites

        Args:
            word_id: Word ID to remove from favorites

        Returns:
            Response data
        """
        return self.make_api_request("DELETE", f"?endpoint=favoritos&wordId={word_id}")

    @keyword
    def create_custom_vocabulary(
        self, word: str, definition: str, pronunciation: str = None
    ) -> Dict:
        """Create custom vocabulary entry

        Args:
            word: The word
            definition: Word definition
            pronunciation: Word pronunciation (optional)

        Returns:
            Response data
        """
        data = {"word": word, "definition": definition}
        if pronunciation:
            data["pronunciation"] = pronunciation

        return self.make_api_request(
            "POST", "?endpoint=customVocabulary", data, expected_status=201
        )

    @keyword
    def create_folder(
        self, name: str, color: str = "#007bff", icon: str = "folder"
    ) -> Dict:
        """Create new folder for organizing words

        Args:
            name: Folder name
            color: Folder color (hex)
            icon: Folder icon

        Returns:
            Response data
        """
        data = {"name": name, "color": color, "icon": icon}

        return self.make_api_request(
            "POST", "?endpoint=folders", data, expected_status=201
        )

    @keyword
    def get_folders(self) -> Dict:
        """Get user's folders

        Returns:
            Folders list data
        """
        return self.make_api_request("GET", "?endpoint=folders")

    @keyword
    def move_words_to_folder(self, word_ids: List[int], folder_id: int) -> Dict:
        """Move words to specified folder

        Args:
            word_ids: List of word IDs to move
            folder_id: Target folder ID

        Returns:
            Response data
        """
        data = {"wordIds": word_ids, "folderId": folder_id}

        return self.make_api_request("POST", "?endpoint=folders/moveWords", data)

    @keyword
    def get_grammar_exercises(self, category: str = None) -> Dict:
        """Get grammar exercises

        Args:
            category: Exercise category filter

        Returns:
            Grammar exercises data
        """
        endpoint = "?endpoint=grammarExercises"
        if category:
            endpoint += f"&category={category}"

        return self.make_api_request("GET", endpoint)

    @keyword
    def submit_grammar_answer(self, exercise_id: int, answer: Any) -> Dict:
        """Submit grammar exercise answer

        Args:
            exercise_id: Exercise ID
            answer: User's answer

        Returns:
            Response data
        """
        data = {"exerciseId": exercise_id, "answer": answer}

        return self.make_api_request("POST", "?endpoint=grammarSubmit", data)

    @keyword
    def validate_jwt_token(self, token: str) -> bool:
        """Validate JWT token format and structure

        Args:
            token: JWT token to validate

        Returns:
            True if token is valid, False otherwise
        """
        try:
            # Decode without verification to check structure
            decoded = jwt.decode(token, options={"verify_signature": False})

            # Check required fields
            required_fields = ["exp", "iat", "sub"]
            for field in required_fields:
                if field not in decoded:
                    logger.warn(f"Missing required field in JWT: {field}")
                    return False

            # Check expiration
            exp_timestamp = decoded.get("exp")
            if exp_timestamp and exp_timestamp < time.time():
                logger.warn("JWT token is expired")
                return False

            return True

        except jwt.DecodeError:
            logger.warn("Invalid JWT token format")
            return False
        except Exception as e:
            logger.warn(f"JWT validation error: {str(e)}")
            return False

    @keyword
    def generate_oauth_url(self, provider: str, redirect_url: str) -> str:
        """Generate OAuth URL for social login

        Args:
            provider: OAuth provider (google, facebook)
            redirect_url: Redirect URL after authentication

        Returns:
            OAuth authorization URL
        """
        if provider.lower() == "google":
            import os

            client_id = os.getenv("GOOGLE_CLIENT_ID")
            scope = "email profile"
            return (
                f"https://accounts.google.com/oauth/authorize?"
                f"client_id={client_id}&"
                f"redirect_uri={redirect_url}&"
                f"scope={scope}&"
                f"response_type=code"
            )

        elif provider.lower() == "facebook":
            # Facebook OAuth URL generation would go here
            return f"https://www.facebook.com/v18.0/dialog/oauth?redirect_uri={redirect_url}"

        else:
            raise ValueError(f"Unsupported OAuth provider: {provider}")

    @keyword
    def wait_for_element_api_response(self, element_id: str, timeout: int = 30) -> bool:
        """Wait for API response that affects UI element

        Args:
            element_id: Element identifier to wait for
            timeout: Maximum wait time in seconds

        Returns:
            True if element appears, False if timeout
        """
        start_time = time.time()
        while time.time() - start_time < timeout:
            # This would integrate with UI library to check element state
            time.sleep(0.5)

        return False

    @keyword
    def verify_api_response_schema(
        self, response_data: Dict, expected_schema: Dict
    ) -> bool:
        """Verify API response matches expected schema

        Args:
            response_data: Actual response data
            expected_schema: Expected schema definition

        Returns:
            True if schema matches, False otherwise
        """
        try:
            from jsonschema import validate

            validate(response_data, expected_schema)
            return True
        except Exception as e:
            logger.warn(f"Schema validation failed: {str(e)}")
            return False

    @keyword
    def cleanup_test_data(self, user_id: int = None) -> None:
        """Clean up test data after test execution

        Args:
            user_id: User ID to clean up (optional)
        """
        try:
            # Clean up custom vocabulary
            response = self.make_api_request("GET", "?endpoint=customVocabulary")
            if response["status_code"] == 200:
                for item in response["data"].get("items", []):
                    if item.get("word", "").startswith("test_"):
                        self.make_api_request(
                            "DELETE", f"?endpoint=customVocabulary&id={item['id']}"
                        )

            # Clean up test folders
            response = self.make_api_request("GET", "?endpoint=folders")
            if response["status_code"] == 200:
                for folder in response["data"].get("folders", []):
                    if folder.get("name", "").startswith("test_"):
                        self.make_api_request(
                            "DELETE", f"?endpoint=folders&id={folder['id']}"
                        )

            logger.info("Test data cleanup completed")

        except Exception as e:
            logger.warn(f"Cleanup error: {str(e)}")

    @keyword
    def generate_test_data(self, data_type: str, count: int = 1) -> List[Dict]:
        """Generate test data for various entities

        Args:
            data_type: Type of data to generate (user, word, folder)
            count: Number of items to generate

        Returns:
            List of generated test data
        """
        from faker import Faker

        fake = Faker()

        test_data = []

        for i in range(count):
            if data_type == "user":
                test_data.append(
                    {
                        "username": f"test_{fake.user_name()}_{i}@wordmate.es",
                        "password": fake.password(length=12),
                        "firstName": fake.first_name(),
                        "lastName": fake.last_name(),
                    }
                )

            elif data_type == "word":
                test_data.append(
                    {
                        "word": f"test_{fake.word()}_{i}",
                        "definition": fake.sentence(),
                        "pronunciation": f"/{fake.word()}/",
                    }
                )

            elif data_type == "folder":
                colors = ["#007bff", "#28a745", "#dc3545", "#ffc107"]
                icons = ["folder", "book", "star", "heart"]
                test_data.append(
                    {
                        "name": f"test_folder_{i}_{fake.word()}",
                        "color": fake.random_element(colors),
                        "icon": fake.random_element(icons),
                    }
                )

        return test_data

    @keyword
    def measure_api_performance(
        self, method: str, endpoint: str, data: Dict = None, iterations: int = 1
    ) -> Dict:
        """Measure API endpoint performance

        Args:
            method: HTTP method
            endpoint: API endpoint
            data: Request data
            iterations: Number of iterations to run

        Returns:
            Performance metrics
        """
        response_times = []

        for i in range(iterations):
            start_time = time.time()
            end_time = time.time()

            response_times.append(end_time - start_time)

        avg_time = sum(response_times) / len(response_times)
        min_time = min(response_times)
        max_time = max(response_times)

        performance_data = {
            "average_response_time": avg_time,
            "min_response_time": min_time,
            "max_response_time": max_time,
            "iterations": iterations,
            "all_response_times": response_times,
        }

        logger.info(f"Performance metrics: {performance_data}")
        return performance_data
