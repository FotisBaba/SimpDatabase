package batabases;

import java.sql.*;
import java.util.*;

public class Vaseis {

	private static Boolean connected=false;
	private Connection conn;
	
	public Vaseis(){
		try{
			Class.forName("org.postgresql.Driver");
		
		} catch (ClassNotFoundException e){
			System.out.println("Catched!");
			e.printStackTrace();
		}
	}
	
	public void dbConnect(){ //1, 2
		try {
			Scanner scanner = new Scanner(System.in);

			System.out.println("Enter database IP: ");
			String db_IP = scanner.nextLine();
			
			System.out.println("Enter database name: ");
			String database = scanner.nextLine();
			
			System.out.println("Enter user name: ");
			String username = scanner.nextLine();
	
			System.out.println("Enter user password: ");
			String password = scanner.nextLine();
			
			conn = DriverManager.getConnection(db_IP+database, username, password);
			conn.setAutoCommit(false);
			connected = true;
		
		} catch(SQLException e){
			
			e.printStackTrace();
		}
	}
	
	public void closeConnection(){ //3
		try {
			conn.close();
			connected = false;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	public void commit(){
		try {
			conn.commit();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	public void rollback(){
		try {
			conn.rollback();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	

	
	public void showEnroledStudents(String year, String semester, String coursecode){ //4
		try {
			PreparedStatement prprdres = null;
			
			String prprdstmt = "SELECT s.name, s.surname FROM \"Student\" s JOIN \"Register\" r ON r.register_status='approved' "
					+ "JOIN \"Course\" c ON c.typical_season = ? ,c.typical_year = ? , c.course_code = ?";
			prprdres = conn.prepareStatement(prprdstmt);
			
			

			
			while(prprdres.getResultSet() != null){
				System.out.println(prprdres.getResultSet());
			}
			prprdres.close();
		
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	

	
	
	public void showStudentGrades(String year, String semester, String amka){ //5
		
		
		try {
			PreparedStatement prprdres = null;
			
			String prprdstmt = "SELECT count(course_code) AS count c.course_code, c.course_title, r.lab_grade, r.exam_grade "
					+ "FROM \"Register\" r JOIN \"Course\" c ON c.course_code=r.course_code, c.typical_season = ?, c.typical_year = ? "
					+ "JOIN \"Student\" s ON s.amka = ?";
			prprdres = conn.prepareStatement(prprdstmt);

			while(prprdres.getResultSet() != null){
				System.out.println(prprdres.getResultSet());
			}
			prprdres.close();
		
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
		
		
	}
	

	
	public static void main(String[] args){
		int choice;
		Vaseis dbapp = new Vaseis();

		do {
			
			System.out.println( "Choose an option:\n1) Insert database info to log in\n"
							  + "2) New session\n"
							  + "3) End session\n"
							  + "4) Show enroled students\n"
							  + "5) Show student grades\n"
							  + "0) Exit program\n");
			
			Scanner scanIn = new Scanner(System.in);
			choice = scanIn.nextInt();
			
			switch(choice) {
			case 1:
				if(connected)
					System.out.println("Already connected!\n");
				else
					dbapp.dbConnect();
				break;
				
			case 2:
				if(connected){
					dbapp.closeConnection();
					dbapp.dbConnect();
				}else
					System.out.println("Not connected!\n");
				break;
				
			case 3:
				if(connected){
					dbapp.closeConnection();
					System.out.println("Disconnect successful!\n");
				}
				else 
					System.out.println("Not connected!\n");
				break;
				
			case 4:
				if(connected) {
					
					Scanner tmp = new Scanner(System.in);

					String yea = tmp.nextLine();
					String sem = tmp.nextLine();
					String code = tmp.nextLine();
					
					dbapp.showEnroledStudents(yea, sem , code);
					System.out.println("");
				}else
					System.out.println("Not connected!\n");
				break;
				
			case 5:
				if(connected) {
					Scanner tmp = new Scanner(System.in);

					String yea = tmp.nextLine();
					String sem = tmp.nextLine();
					String amk = tmp.nextLine();
					
					dbapp.showStudentGrades(yea, sem , amk);
					System.out.println("");
				}else
					System.out.println("Not connected!\n");
				break;
				
				
			case 0:
				if(connected){
					dbapp.closeConnection();
				}
				System.out.println("eXITING!");
				break;
				
			default:
				System.out.println("Option invalid! Try again?\n");
				break;
			}
			
		}while (choice != 0);
	}
	
}