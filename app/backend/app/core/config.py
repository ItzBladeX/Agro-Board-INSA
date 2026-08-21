from pydantic_settings import BaseSettings, SettingsConfigDict
class Settings(BaseSettings):
    sqlite_url: str

    # JWT settings
    jwt_secret: str 
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int 

    model_config = SettingsConfigDict(env_file=".env")


settings = Settings()  