"""Flask Cat Facts API Application.

This module implements a simple Flask web application that fetches and displays
random cat facts from the Cat Facts API.
"""

import logging

import requests
from flask import Flask, render_template, request

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CAT_FACTS_API = "https://catfact.ninja/facts"
DOG_API = "https://dog.ceo/api/breeds/image/random"


@app.route("/", methods=["GET", "POST"])
def index():
    """Render the main page and handle form submissions.

    Returns:
        str: Rendered HTML template with cat facts and dog images.
    """
    cat_facts = []
    dog_image = None
    error = None
    limit = 5

    if request.method == "POST":
        try:
            limit = int(request.form.get("limit", 5))
            if limit < 1 or limit > 10:
                limit = 5
        except ValueError:
            limit = 5

        # Fetch cat facts
        try:
            response = requests.get(CAT_FACTS_API, params={"limit": limit}, timeout=5)
            response.raise_for_status()
            data = response.json()
            cat_facts = data.get("data", [])
            logger.info(f"Fetched {len(cat_facts)} cat facts")
        except requests.exceptions.RequestException as e:
            logger.error(f"Error fetching cat facts: {e}")
            error = "Failed to fetch cat facts. Please try again."

        # Fetch dog image
        try:
            response = requests.get(DOG_API, timeout=5)
            response.raise_for_status()
            data = response.json()
            dog_image = data.get("message")
            logger.info("Fetched dog image")
        except requests.exceptions.RequestException as e:
            logger.error(f"Error fetching dog image: {e}")

    return render_template(
        "index.html", cat_facts=cat_facts, dog_image=dog_image, error=error, limit=limit
    )


@app.route("/health")
def health():
    """Health check endpoint for Kubernetes probes.

    Returns:
        dict: Health status.
    """
    return {"status": "healthy"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
