# ALEO-P_CARD
Aleo-One Pass is an innovative zero-knowledge proof card generated through the Leo programming language. This unique card is designed specifically for the address [self.caller], serving a dual purpose: facilitating future asset purchases and acting as an identity verification method for the associated wallet address.

# Features/Functionality
1. **Card Generation:**
   - The `generate_card` transition mints a unique Aleo card, associating it with the specified owner, card number, CVV, and amount.
   - Utilizes cryptographic hashing functions to generate secure and unique identifiers for the card components.
   - Returns a card object with hashed details.

2. **Faucet Access:**
   - The `get_faucet` transition allows the owner to access a simulated faucet, generating a card similar to the generation process.
   - Ensures that the caller is the owner before providing the faucet.
   - Implements a finalize step to record the owner's increased balance after obtaining the faucet.

3. **Unique Asset ID Acquisition:**
   - The `get_asset` transition enables the owner to acquire a unique asset ID associated with their card.
   - Validates the caller against the asset's owner and adjusts the card's amount.
   - Determines the card type based on the provided `CardUsage` structure.
   - Finalizes the process by updating the owner's balance, asset ownership, and returning the modified card, asset ID, and card type.




https://github.com/Elexy101/ALEO-P_CARD/assets/24855083/1505585a-a963-475a-90d1-8a783675bf23

