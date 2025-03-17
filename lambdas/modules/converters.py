import decimal

def convert_decimal(obj):
    # Recursively convert decimals to int type as JSON doesn't accept decimals.
    
    if isinstance(obj, list):
        return [convert_decimal(i) for i in obj]
    elif isinstance(obj, dict):
        return {k: convert_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, decimal.Decimal):
        return int(obj) 
    return obj