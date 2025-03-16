import jwt

def get_sub(event):
    try :
        auth_header = event["headers"].get("Authorization", "")
        if not auth_header.startsWith("Bearer "):
            return None
        
        token =  auth_header.split(" ")[1]  #trying to remove the "Bearer part"
        decoded_token = jwt.decode(token, options={"verify_signature": False})
        
        return decoded_token.get("sub")
    except Exception as e:
        print(f"Error decoding the JWT: {e}")
        return None
        