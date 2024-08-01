# ALEO-P_CARD
Aleo-One Pass is an innovative zero-knowledge proof card generated through the Leo programming language. This unique card is designed specifically for the address [self.caller], serving a dual purpose: facilitating future asset purchases and acting as an identity verification method for the associated wallet address.

# Features/Functionality
1. **Card Generation:**
   - The `generate_card` transition mints a unique Aleo card, associating it with the specified owner, card number, CVV.
   - Utilizes cryptographic hashing functions to generate secure and unique identifiers for the card components.
   - Returns a card object with hashed details.

   ## LEO-CLI
   `leo run generate_card <address> <number1>u64 <number2>u8` where
   <address> - self.caller/owner
   <number1> - card number 
   <number2> - card CVV

3. **Faucet Access:**
   - The `get_faucet` transition allows the owner to access a simulated faucet, generating a card similar to the generation process.
   - Ensures that the caller is the owner before providing the faucet.
   - Implements a finalize step to record the owner's increased balance after obtaining the faucet.

     ## LEO-CLI
     `leo run get_faucet <address> <number1>u64 <number2>u8`

4. **Unique Asset ID Acquisition:**
   - The `get_asset` transition enables the owner to acquire a unique asset ID associated with their card.
   - Validates the caller against the asset's owner and adjusts the card's amount.
   - Determines the card type based on the provided `CardUsage` structure.
   - Finalizes the process by updating the owner's balance, asset ownership, and returning the modified card, asset ID, and card type.
   - for now, only `purchasing_estate` is alllowed. more assets will be included after testing phase 1

     ## LEO-CLI
     `leo run purchasing_estate <address> <number1>u64 <number2>u8`

5. **Send an Asset**
   - The self.caller of the card owner can send an asset based on its ID associated with their card to another owner
   - As a testing phase 1, send this asset to an owner who have not gotten faucet nor purchase any unique asset

     ## LEO-CLI
     `leo run send_estate_id <receiver_address> <asset_id>u64`
     


# WEBPAGE PREVIEW
https://github.com/user-attachments/assets/368ddc56-d896-4ca3-918d-bb48b5cafb6a



# LEO-CLI PREVIEW
https://github.com/Elexy101/ALEO-P_CARD/assets/24855083/1505585a-a963-475a-90d1-8a783675bf23

