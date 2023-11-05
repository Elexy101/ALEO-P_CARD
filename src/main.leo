// The 'aleo_card' program.
program aleo_card.aleo {

    record card {
        owner: address,
        number: u64,
        cvv: u8,
        amt: u64,
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
        let hash_number: u64 = BHP256:: hash_to_u64(owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(owner);

        let my_card : card = card {
            owner: owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: amt,
        };
        return (my_card) then finalize (self.caller, amt);
    }
    finalize generate_card(owner: address, amt: u64){
        // Decrements `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - amt);
    }

    //getting faucet at first
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
        return (my_faucet) then finalize (self.caller, amt);
    }
    
    finalize get_faucet(owner: address, amt: u64) {
        //Increments `account[owner]` by  `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + amt);
    }
    

    //getting the asset unique id
    transition get_asset(asset: card) -> (card, u32) {
        check_addr(asset.owner);
        let hash_number: u64 = BHP256:: hash_to_u64(asset.owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(asset.owner);
        let new_amt: u64 = asset.amt - 10u64;

        //set asset for self.caller
        let asset_id: u32 = BHP256:: hash_to_u32(hash_number);

        let purchase_asset : card = card {
            owner: asset.owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: new_amt,
        };
        return (purchase_asset, asset_id) then finalize (self.caller, new_amt, asset_id);
    }
    
    finalize get_asset(owner: address, new_amt: u64, asset_id: u32) {
        //Decrements `account[owner]` by  `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - new_amt);

        //Increment asset of `account[owner]` 
        Mapping::set(asset_owner, owner, asset_id);
    }

}
