// The 'aleo_card' program.

//==============================================================================
//================= ALEO PASS CARD SMART ALEO CONTRACT =========================
//+++ self.caller gets faucet to mint a pass card that will needed for other +++
//++ upcoming project and can serve as a whitelist to projects, just a test:) ++
//==============================================================================

program aleo_card_v6.aleo {

    record card {
        owner: address,
        number: u64,
        cvv: u8,
        amt: u64,
    }

    struct CardUsage {
        data1: u8, // Part 1 of the bdata uri in bits. Bits should be the representation of the hexadecimal bytes for the ASCII text of the URL
    }

    //setting data for each item [Food, Travel, Real Estate, Stocks] 
    struct CardDATA  {
        card_owner: address,
        food: u64,
        travel: u64,
        estate: u64,
        stocks: u64,
    }

    struct ITEM_ID {
        food_id: u64,
        travel_id: u64,
        estate_id: u64,
        stocks_id: u64,
    }

    //admin control
    struct GlobalState {
        // The id of token to be created by the next call to create_token
        next_token_id: field,
        admin: address,
    }


    //TestToken => Testing token (MAX PER USER -> 10,000 token)
    struct TestToken {
        name: field,
        symbol: field,
        decimals: u8,
        faucet_circulating_supply: u64,
        faucet_total_supply: u64,
        admin: address,
    }

    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    //mapping asset
    mapping asset_owner: address => u32;

    //mapping is required
    mapping card_data: u64 => CardDATA;

    //mapping is required
    mapping item_id: u64 => ITEM_ID;

    //global mapping admin
    mapping global_state: bool => GlobalState;

    //now i am the admin of the test token owning over 6000000u64 token
    mapping test_token: u64 => TestToken;

    //check address = self.caller
    inline check_addr(owner: address) -> bool {
        assert_eq(self.caller, owner);
        return true;
    }



  //==========================================================================
   // ============================ admin control ==============================
   //==========================================================================
    // Initialize the program after deployment.
    async transition init(b: bool) -> (address, Future) {
        return (self.caller, init_finalize(self.caller));
    }

    async function init_finalize(caller: address) {
        // init global state
        let gs: GlobalState = Mapping::get_or_use(global_state, true, GlobalState {
            next_token_id: 0field,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m,
        });
        assert_eq(gs.next_token_id, 0field);
        assert_eq(caller, gs.admin);
        Mapping::set(global_state, true, GlobalState {
            next_token_id: 1field,
            admin: gs.admin,
        });

        // init token
        let test_supply: u64 = 10000000u64; //10 million token allocated
        //admin token amt => for testing sale mechanism 60000000 token allocated to admin
        let admin_token_amt: u64 = 6000000u64;
        //test admin by adding some token to admin => 6000000u64
        let owner_amount: u64 = Mapping::get_or_use(account, caller, 0u64);
        assert(owner_amount == 0u64);
        // Increments `account[to_address]` by `amount`.
        Mapping::set(account, caller, owner_amount + admin_token_amt); 

        Mapping::set(test_token, test_supply, TestToken {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            faucet_circulating_supply: 0u64 + admin_token_amt,
            faucet_total_supply: test_supply,
            admin: gs.admin,
        });

    }

    //========================================================================================
    //====================== Change the main admin of the program. ===========================
    //========================================================================================

    async transition change_admin(admin: address) -> (address, Future) {
        //OnlyAdmin
        //admin = aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m;
        return (admin, finalize_change_admin(self.caller));
    }

    async function finalize_change_admin(admin: address) {
        let gs: GlobalState = Mapping::get(global_state, true);
        assert_eq(admin, gs.admin);
        Mapping::set(global_state, true, GlobalState {
            next_token_id: gs.next_token_id,
            admin: admin,
        });
    }


    //mint aleo card => generate_card function is for test simulation

    transition generate_card(owner: address, number: u64, cvv: u8) -> (card){
        check_addr(owner);
        let hash_owner: field = BHP256::hash_to_field(owner);
        let hash_number: u64 = BHP256:: hash_to_u64(owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(cvv);

        //amount
        let amt: u64 = 0u64;

        let my_card : card = card {
            owner: owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: amt,
        };
        return (my_card);
    }

    

    //================ GET FAUCET TO TEST ====================
    async transition get_faucet(owner: address, number: u64, cvv: u8) -> (card, Future) {
        check_addr(owner);
        let hash_number: u64 = BHP256:: hash_to_u64(owner);
        let hash_cvv: u8 = BHP256:: hash_to_u8(owner);

        let amt: u64 = 1000u64;

        let my_faucet : card = card {
            owner: owner,
            number: hash_number,
            cvv: hash_cvv,
            amt: amt,
        };
        return (my_faucet, finalize_get_faucet(owner, amt));
    }
    
    async function finalize_get_faucet(public owner: address, public amt: u64) {

        let test_token_info: TestToken = Mapping::get_or_use(test_token, 10000000u64, TestToken {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            faucet_circulating_supply: 0u64,
            faucet_total_supply: 0u64,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m,
        });

        //check if user have faucet already, otherwise throw error
        let faucet_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_eq(faucet_exists, 0u64);

        //checking if faucet_circulating supply < amount is less than 4million token[4,000 users only]
        assert(test_token_info.faucet_circulating_supply <= 4000000u64);

        //Increments `account[owner]` by  `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + amt);

        Mapping::set(test_token, 10000000u64, TestToken {
            name: test_token_info.name,
            symbol: test_token_info.symbol,
            decimals: test_token_info.decimals,
            faucet_circulating_supply: test_token_info.faucet_circulating_supply + amt,
            faucet_total_supply: test_token_info.faucet_total_supply,
            admin: test_token_info.admin,
        });

    }
    

    //==================================================================================
    //========================== estate purchase transtion ===============================
    //==================================================================================
    async transition purchasing_estate(owner: address, number: u64, cvv: u8) -> (Future){
        check_addr(owner);
        return (finalize_purchasing_estate(owner, number, cvv));
    }
    async function finalize_purchasing_estate(owner: address, number: u64, cvv: u8){
        //check if user have requested faucet yet above 0u64, otherwise throw error
        let faucet_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_neq(faucet_exists, 0u64);

        //calling the mapping from the struct
        let call_data: CardDATA = Mapping::get_or_use(card_data, number, CardDATA {
            card_owner: owner,
            food: 0u64,
            travel: 0u64,
            estate: 0u64,
            stocks: 0u64,
        });

        //calling the mapping from the struct ITEM_ID
        let call_item: ITEM_ID = Mapping::get_or_use(item_id, number, ITEM_ID {
            food_id: 0u64,
            travel_id: 0u64,
            estate_id: 0u64,
            stocks_id: 0u64,
        });

        //creating hash asset id for a user => estate
        let global_estate_id: u64 = 10111511697116101u64; //python convert `estate` to `u64`
        let hash_user: u64 = BHP256:: hash_to_u64(owner);
        let hash_estate_id: u64 = BHP256:: hash_to_u64(hash_user + global_estate_id);

        //setting price for food -? tracking food item
        let estate_per_price: u64 = 500u64;
        Mapping::set(account, owner, faucet_exists - estate_per_price);
        Mapping::set(card_data, number, CardDATA {
            card_owner: owner,
            food: call_data.food,
            travel: call_data.travel,
            estate: call_data.estate + estate_per_price,
            stocks: call_data.stocks,
        });
        
        //setting the food id per user
        Mapping::set(item_id, number, ITEM_ID {
            food_id: call_item.food_id,
            travel_id: call_item.travel_id,
            estate_id: hash_estate_id,
            stocks_id: call_item.stocks_id,
        });
    }



    async transition send_estate_asset(receiver: address, asset_id: u64) -> (Future){
        let owner: address = self.caller;
        return finalize_send_estate_asset(owner, receiver, asset_id);
    }
    async function finalize_send_estate_asset(owner: address, receiver: address, asset_id: u64){
        assert_neq(owner, receiver); //checks that owner != receiver
        
        //lets hash the owner, receiver
        let hash_owner: u64 = BHP256:: hash_to_u64(owner);
        let hash_receiver: u64 = BHP256:: hash_to_u64(receiver);


        //calling the mapping from the struct ITEM_ID
        let call_item: ITEM_ID = Mapping::get_or_use(item_id, asset_id, ITEM_ID {
            food_id: 0u64,
            travel_id: 0u64,
            estate_id: 0u64,
            stocks_id: 0u64,
        });

        assert(call_item.estate_id == asset_id);

        //creating hash asset id for a user => estate
        let global_estate_id: u64 = 10111511697116101u64; //python convert `estate` to `u64`
        let hash_estate_id: u64 = BHP256:: hash_to_u64(hash_owner + global_estate_id);

        //setting the food id per user
        Mapping::set(item_id, hash_receiver, ITEM_ID {
            food_id: call_item.food_id,
            travel_id: call_item.travel_id,
            estate_id: hash_estate_id,
            stocks_id: call_item.stocks_id,
        });

        //removing mapping for owner
        Mapping::remove(item_id, hash_owner);
    }

}
