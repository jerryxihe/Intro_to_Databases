import java.net.URL;
import java.sql.*;
import java.util.Date;
import java.util.Arrays;
import java.util.List;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    // Can use if you wish: seat letters
    List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects and sets the search path.
     *
     * Establishes a connection to be used for this session, assigning it to the
     * instance variable 'connection'. In addition, sets the search path to
     * 'air_travel, public'.
     *
     * @param url      the url for the database
     * @param username the username to connect to the database
     * @param password the password to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(URL, username, password);
            if (connection.isValid(3) == true) {
                String queryString = "SET SEARCH_PATH TO air_travel, public;";
                PreparedStatement pStatement = connection.prepareStatement(queryString);
                pStatement.executeUpdate();
                return true;
            } else {
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Closes the database connection.
     *
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
        try {
            connection.close();
            if (connection.isClosed()) {
                return true;
            } else {
                return false;
            }
        } catch (SQLException e) {
            return false;
        }
    }

    /* ======================= Airline-related methods ======================= */

    /**
     * Attempts to book a flight for a passenger in a particular seat class. Does so
     * by inserting a row into the Booking table.
     *
     * Read handout for information on how seats are booked. Returns false if seat
     * can't be booked, or if passenger or flight cannot be found.
     *
     * 
     * @param passID    id of the passenger
     * @param flightID  id of the flight
     * @param seatClass the class of the seat (economy, business, or first)
     * @return true if the booking was successful, false otherwise.
     */
    public boolean bookSeat(int passID, int flightID, String seatClass) {
        // Define variables
        String queryString;
        PreparedStatement pStatement;
        ResultSet rs;
        Integer id;

        // Check that flight exists
        Boolean flightExists = false;
        try {
            queryString = "SELECT * FROM flight;";
            pStatement = connection.prepareStatement(queryString);
            rs = pStatement.executeQuery();
            while (rs.next()) {
                id = rs.getInt("id");
                // Iterate through all flights and check if IDs match
                if (id == flightID) {
                    flightExists = true;
                    break;
                }
            }
            System.out.println("flightExists:");
            System.out.println(flightExists);
            // If no matching IDs were found, then flight does not exist
            if (flightExists == false) {
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // Check that passenger exists
        Boolean passengerExists = false;
        try {
            queryString = "SELECT * FROM passenger;";
            pStatement = connection.prepareStatement(queryString);
            rs = pStatement.executeQuery();
            while (rs.next()) {
                id = rs.getInt("id");
                // Iterate through all passengers and check if IDs match
                if (id == passID) {
                    passengerExists = true;
                    break;
                }
            }
            System.out.println("passengerExists");
            System.out.println(passengerExists);
            // If no matching IDs were found, then passenger does not exist
            if (passengerExists == false) {
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // Check that flight is not already full
        // Get number of occupied seats in each class for all flight IDs along
        // with the number of available seats in each seat class
        String foundSeatClass;
        Integer classCapacity = -1;
        Integer classOccupied = -1;
        Integer seatsAvailable;
        try {
            queryString = "SELECT flight_id, seat_class, count(*) as occupied, "
                    + "capacity_economy, capacity_business, capacity_first " + "FROM booking " + "JOIN flight "
                    + "ON booking.flight_id = flight.id " + "JOIN plane " + "ON flight.plane = plane.tail_number "
                    + "GROUP BY flight_id, seat_class, plane, "
                    + "capacity_economy, capacity_business, capacity_first;";
            pStatement = connection.prepareStatement(queryString);
            rs = pStatement.executeQuery();
            while (rs.next()) {
                // Get flight ID and seat class
                id = rs.getInt("flight_id");
                foundSeatClass = rs.getString("seat_class");
                // Check for match
                if (id == flightID && foundSeatClass == seatClass) {
                    // Gather data for seat class that customer wants to book
                    classOccupied = rs.getInt("occupied");
                    switch (seatClass) {
                        case "economy":
                            // Allow overbooking of 10 seats
                            classCapacity = rs.getInt("capacity_economy") + 10;
                            break;
                        case "business":
                            classCapacity = rs.getInt("capacity_business");
                            break;
                        case "first":
                            classCapacity = rs.getInt("capacity_first");
                            break;
                        default:
                            break;
                    }
                }
            }

            // If class is not found then classCapacity will not have been
            // assigned
            if (classCapacity == -1) {
                System.out.println("Class " + seatClass + " not found.");
                return false;
            }
            // Calculate number of seats available
            seatsAvailable = classCapacity - classOccupied;
            if (seatsAvailable <= 0) {
                return false;
            }

            // We now know there are seats available for the specified class
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // Book flight

        return false;
    }

    /**
     * Attempts to upgrade overbooked economy passengers to business class or first
     * class (in that order until each seat class is filled). Does so by altering
     * the database records for the bookings such that the seat and seat_class are
     * updated if an upgrade can be processed.
     *
     * Upgrades should happen in order of earliest booking timestamp first.
     *
     * If economy passengers left over without a seat (i.e. more than 10 overbooked
     * passengers or not enough higher class seats), remove their bookings from the
     * database.
     * 
     * @param flightID The flight to upgrade passengers in.
     * @return the number of passengers upgraded, or -1 if an error occured.
     */
    public int upgrade(int flightID) {
        // Implement this method!
        return -1;
    }

    /* ----------------------- Helper functions below ------------------------- */

    // A helpful function for adding a timestamp to new bookings.
    // Example of setting a timestamp in a PreparedStatement:
    // ps.setTimestamp(1, getCurrentTimeStamp());

    /**
     * Returns a SQL Timestamp object of the current time.
     * 
     * @return Timestamp of current time.
     */
    private java.sql.Timestamp getCurrentTimeStamp() {
        java.util.Date now = new java.util.Date();
        return new java.sql.Timestamp(now.getTime());
    }

    // Add more helper functions below if desired.

    /* ----------------------- Main method below ------------------------- */

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Running the code!");
        Assignment2 classTest;
        try {
            classTest = new Assignment2();
            String url = "jdbc:postgresql://localhost:5432/csc343h-boydfred";
            String username = "boydfred";
            String password = "";
            classTest.connectDB(url, username, password);

            // Test methods
            classTest.bookSeat(5, 10, "economy");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
