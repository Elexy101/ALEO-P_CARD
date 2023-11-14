// The 'aleo_card' program.

//==============================================================================
//================= ALEO PASS CARD SMART ALEO CONTRACT =========================
//+++ self.caller gets faucet to mint a pass card that will needed for other +++
//++ upcoming project and can serve as a whitelist to projects, just a test:) ++
//==============================================================================

program aleo_card.aleo {

    record card {
        owner: address,
        number: u64,
        cvv: u8,
        amt: u64,
    }

    struct CardUsage {
        data1: u8, // Part 1 of the bdata uri in bits. Bits should be the representation of the hexadecimal bytes for the ASCII text of the URL
    }

    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    //mapping asset
    mapping asset_owner: address => u32;

    //check address = self.caller
    function check_addr(owner: address) -> bool {
        if(owner == self.caller){
            assert(true);
        }else{
            assert(false);
        }
        return true;
    }

    //mint aleo card => generate_card function is for test simulation

    transition generate_card(owner: address, number: u64, cvv: u8, amt: u64) -> card{
        check_addr(owner);
        let hash_owner: field = BHP256::hash_to_field(owner);
        let hash_number: u64 = BHP256:: hash_to_u64(owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(owner);

        let my_card : card = card {
            owner: owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: amt,
        };
        return (my_card);
    }

    

    //================ GET FAUCET TO TEST ====================
    transition get_faucet(owner: address, number: u64, cvv: u8, amt: u64) -> card {
        check_addr(owner);
        let hash_number: u64 = BHP256:: hash_to_u64(owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(owner);

        let my_faucet : card = card {
            owner: owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: amt,
        };
        return (my_faucet) then finalize (owner, amt);
    }
    
    finalize get_faucet(owner: address, amt: u64) {
        //check if user have faucet already, otherwise throw error
        let faucet_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_eq(faucet_exists, 0u64);

        //Increments `account[owner]` by  `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + amt);
    }
    

    //================= GET THE UNIQUE ASSET ID ===================
    transition get_asset(asset: card, public card_type: CardUsage) -> (card, u32, u8) {
        check_addr(asset.owner);
        let hash_number: u64 = BHP256:: hash_to_u64(asset.owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(asset.owner);
        let new_amt: u64 = asset.amt - 10u64;

        //Setting setup for card type, the card type is based on => [Food, Travel, Real Estate, Stocks] respectively
        let my_card_type : u8 = 0u8;
        if(card_type.data1 == 1u8){
            my_card_type = 1u8;
        }else if (card_type.data1 == 2u8){
            my_card_type = 2u8;
        }else if(card_type.data1 == 3u8){
            my_card_type = 3u8;
        }else{
            my_card_type = 4u8;
        }

        //set asset for self.caller
        let asset_id: u32 = BHP256:: hash_to_u32(hash_number);

        let purchase_asset : card = card {
            owner: asset.owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: new_amt,
        };
        return (purchase_asset, asset_id, my_card_type) then finalize (asset.owner, new_amt, asset_id);
    }
    
    finalize get_asset(owner: address, new_amt: u64, asset_id: u32) {
        //check if user have requested faucet yet above 0u64, otherwise throw error
        let faucet_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_neq(faucet_exists, 0u64);

        //check if user have asset already, otherwise throw error
        let asset_exists: u32 = Mapping::get(asset_owner, owner) | 0u32;
        assert_eq(asset_exists, 0u32);

        //Decrements `account[owner]` by  `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - new_amt);

        //Increment asset of `asset_owner[owner]` 
        Mapping::set(asset_owner, owner, Mapping::get_or_use(asset_owner, owner, 0u32) + asset_id);
    }

}
