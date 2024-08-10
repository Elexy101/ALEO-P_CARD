
    if (window.leoWallet && window.leoWallet.readyState === "Installed") {
        if (!window.leoWallet.connected) {
            main_connect();
        } else {
            main_disconnect();
        }
    } else {
        console.log("No wallet installed!");
    }
  
  //connected to wallet
    function main_connect() {
      // Check if the wallet is already connected
      if (window.leoWallet) {
        if (!window.leoWallet.connected) {
          // Perform the connection and update the button text
          window.leoWallet.connect("ON_CHAIN_HISTORY", "testnetbeta", ["credits.aleo","aleo_card_v7.aleo"])
            .then(res => {
    
                window.leoWallet.requestRecordPlaintexts("aleo_card_v7.aleo").then(res => console.log(res));
    //sign a message
    let utf8Encode = new TextEncoder();
    let bytes = utf8Encode.encode("Welcome to Aleo-One Pass, This private card can be used for purchasing assets... Maybe Aleo-Monopoly could be the first to test!");
    window.leoWallet.signMessage(bytes);
    
              console.log(res);

              var publicKey = window.leoWallet.publicKey;
              console.log(publicKey);
  
              // Update the button text to "Generate Card"
              //document.getElementById('wallet').innerText = 'Generate Card';
  
              document.getElementById('card-holder-input').value = publicKey;
              document.getElementById('card-holder').innerHTML = publicKey;
              document.getElementById('wallet').innerHTML = publicKey.substring(0, 8) + "..." + publicKey.substring(60,64);

              //======================================================================
              //=================== FAUCET DETECTION =================================
              document.getElementById('faucet-detect').disabled = false;
   


              //QR CODE FOR WALLET 
            var chip = document.getElementById('chip');
            var qrCode = document.getElementById('qr-code');

            const qrCodeData = publicKey; // Replace with your data (e.g., a URL)
            const qr = new QRious({
                element: document.getElementById("qr-code"),
                value: qrCodeData,
                size: 100,
            });

            chip.style.display = 'none';
            qrCode.style.display = 'block';

            //enabled the generate button after connect button
            document.getElementById('generate_').disabled = false;

            })
            .catch(error => {
              console.error("Connection error:", error);
            });
        } else {
          // If the wallet is already connected, you can run other functions here
          console.log("Wallet is already connected.");
          // Run other functions as needed
        }
      } else {
        console.log("No wallet installed!");
      }
    }
  
  //disconnected the wallet
  function main_disconnect() {
        window.leoWallet.disconnect("ON_CHAIN_HISTORY", "testnetbeta")
            .then(res => {
                console.log(res);
                //updateAddressInDatabase_DISCONNECT(); // Call the function to update the address
            })
            .catch(error => {
                console.error("Connection error:", error);
            });
    window.leoWallet.disconnect("ON_CHAIN_HISTORY", "testnetbeta");
    }


    //===========================================================================
    //======================= GENERATE CARD/PAY FUNCTION ========================
    function generate_card() {
    // Get card number and CVV input elements
    const cardNumberInput = document.getElementById('card-number-input');
    const cardCvvInput = document.getElementById('card-secret-cvc-input');
    const faucetInput = document.getElementById('faucet_set');
    const cardType = document.getElementById('card-type-test');

    // Get the submit button
    const submitButton = document.getElementById('generate_');

    // Add a click event listener to the submit button
    submitButton.addEventListener('click', () => {
        // Trim and store the input values
        const cardNumber = cardNumberInput.value.trim();
        const cardCvv = cardCvvInput.value.trim();
        const faucet = faucetInput.value.trim();
        const ccardType = cardType.value.trim();

        // Check if either input is empty
        if (cardNumber === '' || cardCvv === '') {
            alert('Please enter something.');
        } else if (cardNumber.length <= 14 || cardCvv.length <= 2) {
            // Check the length of input values for validity
            alert('Not a valid input card');
        } else {
            // Input is valid
            alert('Input is valid!');

     
                    var publicKey = window.leoWallet.publicKey;
                    console.log(publicKey);

                    if (!publicKey) {
                        throw new WalletNotConnectedError();
                    }
                    var inputs = [publicKey, `${cardNumber}u64`, `${cardCvv}u8`];

                    var aleoTransaction = Transaction.createTransaction(publicKey, 'testnetbeta', 'aleo_card_v7.aleo', 'generate_card', inputs, 500_000);

                    if (aleoTransaction) {
                        window.leoWallet.requestTransaction(aleoTransaction);
                        console.log('Transaction requested successfully.');
                    } else {
                        console.error('requestTransaction function not available.');
                    }
        }
    });
}


    //===========================================================================
    //======================= FAUCET GET TOKEN TEST ========================
function get_faucet(url) {

    // Get card number and CVV input elements
    const cardNumberInput = document.getElementById('card-number-input');
    const cardCvvInput = document.getElementById('card-secret-cvc-input');
    const faucetInput = document.getElementById('faucet_set');

    window.leoWallet.requestRecordPlaintexts("credits.aleo").then(res => console.log(res));

    // Get the submit button
    const submitButton = document.getElementById('faucet-detect');

    // Add a click event listener to the submit button
    submitButton.addEventListener('click', () => {
        // Trim and store the input values
        const cardNumber = cardNumberInput.value.trim();
        //replace the missing spaces
        const cardNumber2 = cardNumber.replace(/\s/g, '');
        const cardCvv = cardCvvInput.value.trim();
        const faucet = faucetInput.value.trim();


        // Check if either input is empty
        if (cardNumber === '' || cardCvv === '') {
            alert('Please enter something.');
        } else if (cardNumber.length <= 14 || cardCvv.length <= 2) {
            // Check the length of input values for validity
            alert('Not a valid input card');
        } else {
            // Input is valid
            alert('Input is valid!');

            // Assume sub_outputDiv is defined elsewhere
            // const sub_outputDiv = outputDiv.substring(16);

            // Connect to the wallet
            window.leoWallet.connect("ON_CHAIN_HISTORY", "testnetbeta", ["aleo_card_v7.aleo"])
                .then(res => {
                    console.log(res);
                    var publicKey = window.leoWallet.publicKey;
                    console.log(publicKey);

                    if (!publicKey) {
                        throw new WalletNotConnectedError();
                    }

                    //input for aleo_card 
                    var inputs = [publicKey, `${cardNumber2}u64`, `${cardCvv}u8`, `${faucet}u64`];

                    var aleoTransaction = Transaction.createTransaction(publicKey, 'testnetbeta', 'aleo_card_v7.aleo', 'generate_card', inputs, 500_000);

                    if (aleoTransaction) {
                        window.leoWallet.requestTransaction(aleoTransaction);
                        console.log('Transaction requested successfully.');
                        console.log(window.leoWallet.TransactionStatus(aleoTransaction)); // transaction status checking...
                    } else {
                        console.error('requestTransaction function not available.');
                    }
                })
                .catch(error => {
                    console.error("Connection error:", error);
                });
        }
    });
}



    //===========================================================================
    //============================ PURCHASE AN ASSET ============================
    function purchase_estate() {

        // Get card number and CVV input elements
        const cardNumberInput = document.getElementById('card_number');
        const cardCvvInput = document.getElementById('card_cvv');
    
        window.leoWallet.requestRecordPlaintexts("credits.aleo").then(res => console.log(res));
    
        // Get the submit button
        const submitButton = document.getElementById('purchase_now');
    
        // Add a click event listener to the submit button
        submitButton.addEventListener('click', () => {
            // Trim and store the input values
            const cardNumber = cardNumberInput.value.trim();
            const cardCvv = cardCvvInput.value.trim();
    
            // Check if either input is empty
            if (cardNumber === '' || cardCvv === '') {
                alert('Please enter something.');
            } else if (cardNumber.length <= 14 || cardCvv.length <= 2) {
                // Check the length of input values for validity
                alert('Not a valid input card');
            } else {
                // Input is valid
                alert('Input is valid!');
    
                // Assume sub_outputDiv is defined elsewhere
                // const sub_outputDiv = outputDiv.substring(16);
    
                // Connect to the wallet
                window.leoWallet.connect("ON_CHAIN_HISTORY", "testnetbeta", ["aleo_card_v7.aleo"])
                    .then(res => {
                        console.log(res);
                        var publicKey = window.leoWallet.publicKey;
                        console.log(publicKey);
    
                        if (!publicKey) {
                            throw new WalletNotConnectedError();
                        }
    
                        //input for aleo_card 
                        var inputs = [publicKey, `${cardNumber}u64`, `${cardCvv}u8`];
    
                        var aleoTransaction = Transaction.createTransaction(publicKey, 'testnetbeta', 'aleo_card_v7.aleo', 'purchasing_estate', inputs, 500_000);
    
                        if (aleoTransaction) {
                            window.leoWallet.requestTransaction(aleoTransaction);
                            console.log('Transaction requested successfully.');
                            console.log(window.leoWallet.TransactionStatus(aleoTransaction)); // transaction status checking...
                        } else {
                            console.error('requestTransaction function not available.');
                        }
                    })
                    .catch(error => {
                        console.error("Connection error:", error);
                    });
            }
        });
    }




    //===========================================================================
    //============================ SENDING  AN ASSET ============================
    function send_asset() {

        // Get card number and CVV input elements
        const receiver = document.getElementById('receiver');
        const asset_id = document.getElementById('asset_id');
    
        window.leoWallet.requestRecordPlaintexts("credits.aleo").then(res => console.log(res));
    
        // Get the submit button
        const submitButton = document.getElementById('send_now');
    
        // Add a click event listener to the submit button
        submitButton.addEventListener('click', () => {
            // Trim and store the input values
            const aleo_receiver = receiver.value.trim();
            const aleo_asset_id = asset_id.value.trim();
    
            // Check if either input is empty
            if (aleo_receiver === '' || aleo_asset_id === '') {
                alert('Please enter something.');
            } else {
                // Input is valid
                alert('Input is valid!');
    
                // Assume sub_outputDiv is defined elsewhere
                // const sub_outputDiv = outputDiv.substring(16);
    
                // Connect to the wallet
                window.leoWallet.connect("ON_CHAIN_HISTORY", "testnetbeta", ["aleo_card_v7.aleo"])
                    .then(res => {
                        console.log(res);
                        var publicKey = window.leoWallet.publicKey;
                        console.log(publicKey);
    
                        if (!publicKey) {
                            throw new WalletNotConnectedError();
                        }
    
                        //input for aleo_card 
                        var inputs = [`${aleo_receiver}`, `${aleo_asset_id}u64`];
    
                        var aleoTransaction = Transaction.createTransaction(publicKey, 'testnetbeta', 'aleo_card_v7.aleo', 'send_estate_asset', inputs, 500_000);
    
                        if (aleoTransaction) {
                            window.leoWallet.requestTransaction(aleoTransaction);
                            console.log('Transaction requested successfully.');
                            console.log(window.leoWallet.TransactionStatus(aleoTransaction)); // transaction status checking...
                        } else {
                            console.error('requestTransaction function not available.');
                        }
                    })
                    .catch(error => {
                        console.error("Connection error:", error);
                    });
            }
        });
    }