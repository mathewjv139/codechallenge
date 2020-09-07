/*
 * Created by: Mathew
 * Description : Apex class to keep commonly used constants in the Apex Classes. 
 * Constants of collection type can be loaded lazily for better use of the CPU time.        
 */

public class Constants {

    public static String FAIL_MOCK_RESPONSE = '{"success":false,"error":"somethings wrong"}';

    public static String SUCCESS_MOCK_RESPONSE = '{"success":true,"secretKey":"secret"}';

    public static string WP_API_NAME = 'Workforce_Planning';

    //lazy loading
    public static Map<String, String> WORKFORCE_PLANNING_FIELD_MAP {
        get {
            if (WORKFORCE_PLANNING_FIELD_MAP == null) WORKFORCE_PLANNING_FIELD_MAP = new Map<String, String>{
                    'id' => 'id',
                    'ownerid' => 'agentid'
                    };
            return WORKFORCE_PLANNING_FIELD_MAP;
        }
        set;
    }   
}
