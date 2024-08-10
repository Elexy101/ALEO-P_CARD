function changeCardBackground(url) {
    document.querySelector('.card-part').style.backgroundImage = "url(" + url + "), linear-gradient(to right bottom, #fd696b, #fa616e, #f65871, #f15075, #ec4879)";

    // Get the clicked category element
    const clickedCategory = event.target.closest('.background-container');

    if (clickedCategory) {
        // Determine the category based on the data-category attribute
        const category = clickedCategory.getAttribute('data-category');

        // Define a mapping of categories to numerical IDs
        const categoryToId = {
            "food": 1,
            "drinks": 2, // Assuming "drinks" corresponds to "Travel"
            "RealEstate": 3, // Fixed typo in category name
            "Stocks": 4,
        };

        // Get the numerical ID for the selected category
        const categoryId = categoryToId[category];

        // Output the numerical ID (1, 2, 3, or 4)
        console.log(`Selected Category ID: ${categoryId}`);

        //pushing output to test 
        document.getElementById('card-type-test').value = categoryId;
    }

}
