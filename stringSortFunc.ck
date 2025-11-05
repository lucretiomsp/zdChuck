// Domenico Cipriani @ 2025

public class AlphaBetaSort {

    // static function that returns a new sorted array
    fun static string[] sort(string input[]) {
        // make a new array of same size
        string output[input.size()];
        
        // copy input to output
        for (0 => int i; i < input.size(); i++) {
            input[i] @=> output[i];
        }

        // bubble sort (alphabetical)
        for (0 => int i; i < output.size(); i++) {
            for (0 => int j; j < output.size() - i - 1; j++) {
                if (output[j] > output[j+1]) {
                    string temp;
                    output[j] @=> temp;
                    output[j+1] @=> output[j];
                    temp @=> output[j+1];
                }
            }
        }

        // return new sorted array
        return output;
    }
}
