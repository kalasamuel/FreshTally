import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Set, Dict

# --- Configuration ---
# Make sure this path is correct relative to where your main.py is running
# If association_rules.pkl is in the same directory, 'association_rules.pkl' is enough.
# If it's in a 'models' subfolder: 'models/association_rules.pkl'
RULES_FILE_PATH = 'association_rules.pkl' # Adjust if your .pkl file is elsewhere

# --- FastAPI App Initialization ---
app = FastAPI(
    title="FreshTally Recommendation API",
    description="API for generating product recommendations based on association rules.",
    version="1.0.0",
)

# Global variable to store loaded association rules
association_rules: pd.DataFrame = pd.DataFrame()

# --- Model Loading on Startup ---
@app.on_event("startup")
async def load_model():
    """
    Loads the association rules model when the FastAPI application starts up.
    """
    global association_rules
    try:
        association_rules = joblib.load(RULES_FILE_PATH)
        print("Association rules loaded successfully on startup.")
        # Ensure 'antecedents' and 'consequents' are in a usable format (e.g., sets of strings)
        # They were saved as strings like "item1, item2" so we need to convert them back
        if not association_rules.empty:
            association_rules['antecedents_set'] = association_rules['antecedents'].apply(lambda x: frozenset(x.split(', ')))
            association_rules['consequents_set'] = association_rules['consequents'].apply(lambda x: frozenset(x.split(', ')))
            print("Antecedents and consequents parsed into sets.")
            # Sort rules by lift for faster recommendation lookup
            association_rules.sort_values(by='lift', ascending=False, inplace=True)
            print("Association rules sorted by lift.")

    except FileNotFoundError:
        print(f"Error: Association rules file not found at {RULES_FILE_PATH}. Recommendations will not be available.")
        # Optionally, raise an error to prevent the app from starting if the model is critical
        # raise RuntimeError(f"Model file not found at {RULES_FILE_PATH}")
    except Exception as e:
        print(f"Error loading association rules: {e}. Recommendations will not be available.")
        # raise RuntimeError(f"Error loading model: {e}")

# --- Pydantic Model for Request Body ---
class RecommendationRequest(BaseModel):
    cart_items: List[str]
    top_n: int = 5 # Default to 5 recommendations

# --- Recommendation Logic Function ---
def get_recommendations_logic(user_cart_items: List[str], top_n: int) -> List[str]:
    """
    Generates product recommendations based on items in the user's cart using loaded rules.
    """
    if association_rules.empty:
        # This case should ideally be handled by the startup event,
        # but provides a fallback if model loading failed.
        print("Warning: Association rules not loaded. Returning empty recommendations.")
        return []

    recommended_items: Set[str] = set()
    user_cart_frozenset = frozenset(user_cart_items)

    # Iterate through the pre-sorted rules
    for _, rule in association_rules.iterrows():
        antecedents_set = rule['antecedents_set']
        consequents_set = rule['consequents_set']

        # Check if all antecedents of the rule are in the user's cart
        # and if the consequents are not already in the cart
        if antecedents_set.issubset(user_cart_frozenset):
            for item in consequents_set:
                if item not in user_cart_frozenset: # Avoid recommending items already in cart
                    recommended_items.add(item)
                    if len(recommended_items) >= top_n:
                        return list(recommended_items)[:top_n]

    return list(recommended_items)[:top_n]


# --- API Endpoint ---
@app.post("/recommendations", response_model=List[str])
async def get_product_recommendations(request: RecommendationRequest):
    """
    Receives a list of items in a user's cart and returns product recommendations.
    """
    if association_rules.empty:
        raise HTTPException(status_code=503, detail="Recommendation service not available. Model not loaded.")
        
    recommended_products = get_recommendations_logic(request.cart_items, request.top_n)
    return recommended_products

# --- Health Check Endpoint (Optional but Recommended) ---
@app.get("/health")
async def health_check():
    """
    Simple endpoint to check if the API is running and the model is loaded.
    """
    model_status = "loaded" if not association_rules.empty else "not loaded"
    return {"status": "ok", "model_status": model_status}