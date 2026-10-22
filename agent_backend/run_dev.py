"""Local development runner: uses dependencies vendored in .pydeps/ (git-ignored) so the system
Python's packages are not upgraded. Production should install requirements.txt in its own env."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".pydeps"))
sys.path.insert(0, HERE)
os.chdir(HERE)

import uvicorn  # noqa: E402

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="127.0.0.1", port=int(os.getenv("PORT", "8090")))
