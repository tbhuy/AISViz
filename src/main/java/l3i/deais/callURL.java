
package l3i.deais;

import java.io.InputStream;
import java.io.IOException;

public class callURL {
    //1
    public String InputStreamToString (InputStream in, int bufSize) {         
        final StringBuilder out = new StringBuilder(); 
        final byte[] buffer = new byte[bufSize]; 
        try {
            for (int ctr; (ctr = in.read(buffer)) != -1;) {
                out.append(new String(buffer, 0, ctr));
            }
        } catch (IOException e) {
            throw new RuntimeException("Cannot convert stream to string", e);
        }
        // On retourne la chaine contenant les donnees de l'InputStream
        return out.toString(); 
    }
    
    //2
    public  String InputStreamToString (InputStream in) {
        // On appelle la methode precedente avec une taille de buffer par defaut
        return InputStreamToString(in, 1024);
    }
    
}
