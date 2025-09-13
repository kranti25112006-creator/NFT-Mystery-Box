module MyModule::NFTMysteryBox {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;
    use std::vector;

    /// Struct representing an NFT Mystery Box
    struct MysteryBox has store, key {
        price: u64,           // Price to open the mystery box
        total_boxes: u64,     // Total number of boxes available
        opened_boxes: u64,    // Number of boxes already opened
        nft_rewards: vector<u64>, // List of NFT IDs that can be won
    }

    /// Struct to represent an opened box result
    struct BoxResult has store, key {
        nft_id: u64,         // The NFT ID received
        opened_at: u64,      // Timestamp when opened
    }

    /// Function to create a new mystery box collection
    public fun create_mystery_box(
        owner: &signer, 
        price: u64, 
        total_boxes: u64
    ) {
        let nft_rewards = vector::empty<u64>();
        
        // Add some sample NFT IDs to the rewards pool
        vector::push_back(&mut nft_rewards, 1001);
        vector::push_back(&mut nft_rewards, 1002);
        vector::push_back(&mut nft_rewards, 1003);
        vector::push_back(&mut nft_rewards, 1004);
        vector::push_back(&mut nft_rewards, 1005);

        let mystery_box = MysteryBox {
            price,
            total_boxes,
            opened_boxes: 0,
            nft_rewards,
        };
        
        move_to(owner, mystery_box);
    }

    /// Function for users to open a mystery box and receive a random NFT
    public fun open_mystery_box(
        user: &signer, 
        box_owner: address
    ) acquires MysteryBox {
        let mystery_box = borrow_global_mut<MysteryBox>(box_owner);
        
        // Check if boxes are still available
        assert!(mystery_box.opened_boxes < mystery_box.total_boxes, 1);
        
        // Pay the box price
        let payment = coin::withdraw<AptosCoin>(user, mystery_box.price);
        coin::deposit<AptosCoin>(box_owner, payment);
        
        // Generate pseudo-random NFT selection based on timestamp
        let current_time = timestamp::now_microseconds();
        let random_index = (current_time % vector::length(&mystery_box.nft_rewards));
        let nft_id = *vector::borrow(&mystery_box.nft_rewards, random_index);
        
        // Update box count
        mystery_box.opened_boxes = mystery_box.opened_boxes + 1;
        
        // Store the result for the user
        let result = BoxResult {
            nft_id,
            opened_at: current_time,
        };
        
        move_to(user, result);
    }
}