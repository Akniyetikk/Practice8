import psycopg2
from connect import get_connection

def run_menu():
    while True:
        print("\n--- PhoneBook Practice 8 Menu ---")
        print("1. Search contacts by pattern")
        print("2. Insert/Update single user")
        print("3. Bulk insert with validation (returns errors)")
        print("4. View contacts with pagination")
        print("5. Delete contact by name or phone")
        print("0. Exit")
        
        choice = input("\nSelect an option: ")

        if choice == '1':
            pattern = input("Enter search pattern: ")
            with get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT * FROM search_contacts(%s);", (pattern,))
                    results = cur.fetchall()
                    for row in results: print(row)

        elif choice == '2':
            name = input("Enter name: ")
            phone = input("Enter phone: ")
            with get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("CALL upsert_contact(%s, %s);", (name, phone))
                    conn.commit()
            print("Done.")

        elif choice == '3':
            names = input("Enter names (comma separated): ").split(',')
            phones = input("Enter phones (comma separated): ").split(',')
            
            with get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("CALL bulk_insert_with_errors(%s, %s, NULL, NULL);", (names, phones))
                    failed_names, failed_phones = cur.fetchone()
                    conn.commit()
                    
                    if failed_names:
                        print("\nIncorrect data rejected by DB:")
                        for n, p in zip(failed_names, failed_phones):
                            print(f"- {n}: {p}")
                    else:
                        print("\nAll records processed successfully.")

        elif choice == '4':
            limit = int(input("How many records per page? "))
            offset = int(input("How many records to skip (offset)? "))
            with get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT * FROM get_contacts_paginated(%s, %s);", (limit, offset))
                    results = cur.fetchall()
                    for row in results: print(row)

        elif choice == '5':
            target = input("Enter name or phone to delete: ")
            with get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("CALL delete_contact(%s);", (target,))
                    conn.commit()
            print("Delete executed.")

        elif choice == '0':
            print("Exiting...")
            break
        else:
            print("Invalid choice, try again.")

if __name__ == "__main__":
    run_menu()
