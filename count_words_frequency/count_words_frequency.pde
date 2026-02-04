// Word frequency visualization from an online text
import java.util.Collections;
import java.util.Comparator;
// Source: http://textfiles.com/stories/100west.txt
// Fetches the text, counts words, and shows a horizontal bar chart of the top words.

String sourceUrl = "http://textfiles.com/stories/100west.txt";
int topN = 20;
ArrayList<WordCount> topWords;
int maxCount = 0;

void setup() {
  size(900, 700);
  background(250);
  textFont(createFont("SansSerif", 14));
  loadAndCount();
  noLoop();
}

void draw() {
  background(250);
  fill(20);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Top " + topN + " words in " + sourceUrl, 20, 20);

  if (topWords == null || topWords.isEmpty()) {
    fill(200, 0, 0);
    text("Could not load or parse the text.", 20, 60);
    return;
  }

  float barMaxWidth = width - 220;
  float y = 80;
  float barH = 22;
  textSize(14);
  for (int i = 0; i < topWords.size(); i++) {
    WordCount wc = topWords.get(i);
    float w = map(wc.count, 0, maxCount, 0, barMaxWidth);
    // bar
    fill(60, 120, 220);
    rect(160, y, w, barH);
    // word label
    fill(10);
    textAlign(RIGHT, CENTER);
    text(wc.word, 150, y + barH/2);
    // count label
    textAlign(LEFT, CENTER);
    text(wc.count, 170 + w, y + barH/2);
    y += barH + 6;
  }
}

void loadAndCount() {
  try {
    String[] lines = loadStrings(sourceUrl);
    if (lines == null) return;
    String all = join(lines, " ").toLowerCase();
    // replace any non-letter characters with spaces
    all = all.replaceAll("[^a-z]", " ");
    String[] words = splitTokens(all, " ");
    HashMap<String, Integer> freq = new HashMap<String, Integer>();
    for (String w : words) {
      if (w.length() == 0) continue;
      Integer c = freq.get(w);
      freq.put(w, c == null ? 1 : c + 1);
    }
    // build sortable list
    ArrayList<WordCount> list = new ArrayList<WordCount>();
    for (String k : freq.keySet()) {
      int c = freq.get(k);
      list.add(new WordCount(k, c));
      if (c > maxCount) maxCount = c;
    }
    // sort descending by count
    Collections.sort(list, new Comparator<WordCount>() {
      public int compare(WordCount a, WordCount b) {
        return b.count - a.count;
      }
    });
    // keep top N
    topWords = new ArrayList<WordCount>();
    for (int i = 0; i < min(topN, list.size()); i++) {
      topWords.add(list.get(i));
    }
  } catch (Exception e) {
    println("Error loading text: " + e.getMessage());
    topWords = null;
  }
}

class WordCount {
  String word;
  int count;
  WordCount(String word, int count) {
    this.word = word;
    this.count = count;
  }
}
