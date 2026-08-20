from unittest.mock import MagicMock, patch
import pytest
from app.models import User
from app.schemas import CreateUserRequest
from app.services import create_user


def test_create_user():
    mock_session = MagicMock()
    #TODO: Add unit tests

    
