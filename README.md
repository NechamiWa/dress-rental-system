## Project Overview
This project is a dress rental system designed to manage the inventory, customers, and rental transactions of a dress rental business. It includes the creation of a relational database to store information about dress models, dresses, customers, rentals, and rental details.

### Key Features:
- **Dress Models and Dresses**: The system allows for adding and managing dress models and their corresponding dresses, which come in various sizes.
- **Customers**: Customer details, including their name, address, phone number, and email, are stored and managed.
- **Rentals**: The system keeps track of rental transactions, including the rental and return dates, and whether the dresses have been returned.
- **Procedures and Triggers**: Several stored procedures help manage operations such as adding new dresses, checking for rented dresses, and updating the rental status. A trigger prevents the deletion of rented dresses to maintain data integrity.

### Main Procedures:
- **Add Dress Line**: A procedure to add a new line of dresses for a given model in multiple sizes.
- **Update Return Status**: This updates the rental return status when a customer returns a dress.
- **Rental Details**: Retrieves rental details for a specific customer.
- **Customer Existence Check**: Verifies if a customer exists in the system.
- **Dress Availability Check**: Determines whether a specific dress is available for rent.
- **Rental Return Days**: Calculates the number of days left until the dress must be returned.

### Usage:
1. **Add new dresses** by calling the `addDressLine` procedure, specifying the model name and the range of sizes.
2. **Rent a dress** by inserting records into the `IRents` and `IRentsDetails` tables for a specific customer and dress.
3. **Update the return status** once the customer has returned the dress.
4. **Check the availability of a dress** to see if it is currently rented.
5. **Track customer rentals** and retrieve their details through simple procedure calls.

### Security:
- A trigger (`tr_prevent_delete_rented_dress`) is implemented to prevent the accidental deletion of rented dresses, ensuring the integrity of the rental data.

## Technologies Used:
- **SQL**: The core database design and operations are built using SQL, with a focus on stored procedures, triggers, and indexing for efficient querying.

## Getting Started:
1. **Database Setup**: Use the provided SQL scripts to set up the database, including tables, stored procedures, and triggers.
2. **Procedures**: Utilize the available stored procedures to manage operations such as adding dresses, managing rentals, and checking inventory.

This project is designed to streamline the process of managing dress rentals, providing a solid foundation for expanding and improving the functionality of the rental business system.