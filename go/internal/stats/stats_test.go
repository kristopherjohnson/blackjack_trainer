package stats

import (
	"testing"
)

// Test initial state of new statistics tracker
func TestInitialState(t *testing.T) {
	stats := New()

	// Check overall accuracy
	if accuracy := stats.GetSessionAccuracy(); accuracy != 0.0 {
		t.Errorf("Initial session accuracy should be 0.0, got %f", accuracy)
	}

	// Check category accuracies
	categories := []string{"hard", "soft", "pair"}
	for _, category := range categories {
		if accuracy := stats.GetCategoryAccuracy(category); accuracy != 0.0 {
			t.Errorf("Initial %s accuracy should be 0.0, got %f", category, accuracy)
		}
	}

	// Check dealer strength accuracies
	strengths := []string{"weak", "medium", "strong"}
	for _, strength := range strengths {
		if accuracy := stats.GetDealerStrengthAccuracy(strength); accuracy != 0.0 {
			t.Errorf("Initial %s accuracy should be 0.0, got %f", strength, accuracy)
		}
	}
}

// Test recording a correct attempt
func TestRecordCorrectAttempt(t *testing.T) {
	stats := New()

	stats.RecordAttempt("hard", "weak", true)

	// Check overall accuracy
	if accuracy := stats.GetSessionAccuracy(); accuracy != 100.0 {
		t.Errorf("Session accuracy after 1 correct should be 100.0, got %f", accuracy)
	}

	// Check category accuracy
	if accuracy := stats.GetCategoryAccuracy("hard"); accuracy != 100.0 {
		t.Errorf("Hard accuracy after 1 correct should be 100.0, got %f", accuracy)
	}

	// Check dealer strength accuracy
	if accuracy := stats.GetDealerStrengthAccuracy("weak"); accuracy != 100.0 {
		t.Errorf("Weak accuracy after 1 correct should be 100.0, got %f", accuracy)
	}
}

// Test recording an incorrect attempt
func TestRecordIncorrectAttempt(t *testing.T) {
	stats := New()

	stats.RecordAttempt("soft", "medium", false)

	// Check overall accuracy
	if accuracy := stats.GetSessionAccuracy(); accuracy != 0.0 {
		t.Errorf("Session accuracy after 1 incorrect should be 0.0, got %f", accuracy)
	}

	// Check category accuracy
	if accuracy := stats.GetCategoryAccuracy("soft"); accuracy != 0.0 {
		t.Errorf("Soft accuracy after 1 incorrect should be 0.0, got %f", accuracy)
	}

	// Check dealer strength accuracy
	if accuracy := stats.GetDealerStrengthAccuracy("medium"); accuracy != 0.0 {
		t.Errorf("Medium accuracy after 1 incorrect should be 0.0, got %f", accuracy)
	}
}

// Test multiple attempts with mixed results
func TestMultipleAttempts(t *testing.T) {
	stats := New()

	// Record various attempts
	stats.RecordAttempt("hard", "weak", true)   // 1/1 correct
	stats.RecordAttempt("hard", "weak", false)  // 1/2 correct
	stats.RecordAttempt("soft", "strong", true) // 2/3 correct
	stats.RecordAttempt("pair", "medium", true) // 3/4 correct

	// Check overall accuracy (75%)
	if accuracy := stats.GetSessionAccuracy(); accuracy != 75.0 {
		t.Errorf("Session accuracy should be 75.0, got %f", accuracy)
	}

	// Check hard category accuracy (50%)
	if accuracy := stats.GetCategoryAccuracy("hard"); accuracy != 50.0 {
		t.Errorf("Hard accuracy should be 50.0, got %f", accuracy)
	}

	// Check soft category accuracy (100%)
	if accuracy := stats.GetCategoryAccuracy("soft"); accuracy != 100.0 {
		t.Errorf("Soft accuracy should be 100.0, got %f", accuracy)
	}

	// Check pair category accuracy (100%)
	if accuracy := stats.GetCategoryAccuracy("pair"); accuracy != 100.0 {
		t.Errorf("Pair accuracy should be 100.0, got %f", accuracy)
	}
}

// Test accuracy calculations with various scenarios
func TestAccuracyCalculations(t *testing.T) {
	stats := New()

	// Add 3 correct out of 4 attempts for hard totals
	stats.RecordAttempt("hard", "weak", true)
	stats.RecordAttempt("hard", "weak", true)
	stats.RecordAttempt("hard", "weak", true)
	stats.RecordAttempt("hard", "weak", false)

	// Check hard accuracy (75%)
	expected := 75.0
	if accuracy := stats.GetCategoryAccuracy("hard"); accuracy != expected {
		t.Errorf("Hard accuracy should be %f, got %f", expected, accuracy)
	}

	// Add 1 incorrect attempt for weak dealer
	stats.RecordAttempt("soft", "weak", false)

	// Check weak dealer accuracy (3 correct out of 5 = 60%)
	expected = 60.0
	if accuracy := stats.GetDealerStrengthAccuracy("weak"); accuracy != expected {
		t.Errorf("Weak dealer accuracy should be %f, got %f", expected, accuracy)
	}
}

// Test dealer strength classification
func TestDealerStrengthClassification(t *testing.T) {
	stats := New()

	// Test weak cards
	weakCards := []int{4, 5, 6}
	for _, card := range weakCards {
		if strength := stats.GetDealerStrength(card); strength != "weak" {
			t.Errorf("Card %d should be classified as weak, got %s", card, strength)
		}
	}

	// Test medium cards
	mediumCards := []int{2, 3, 7, 8}
	for _, card := range mediumCards {
		if strength := stats.GetDealerStrength(card); strength != "medium" {
			t.Errorf("Card %d should be classified as medium, got %s", card, strength)
		}
	}

	// Test strong cards
	strongCards := []int{9, 10, 11}
	for _, card := range strongCards {
		if strength := stats.GetDealerStrength(card); strength != "strong" {
			t.Errorf("Card %d should be classified as strong, got %s", card, strength)
		}
	}
}

// Test invalid categories
func TestInvalidCategories(t *testing.T) {
	stats := New()

	// Test invalid hand type category
	if accuracy := stats.GetCategoryAccuracy("invalid"); accuracy != 0.0 {
		t.Errorf("Invalid category should return 0.0, got %f", accuracy)
	}

	// Test invalid dealer strength category
	if accuracy := stats.GetDealerStrengthAccuracy("invalid"); accuracy != 0.0 {
		t.Errorf("Invalid dealer strength should return 0.0, got %f", accuracy)
	}

	// Recording to invalid categories should not crash
	stats.RecordAttempt("invalid", "invalid", true)

	// Should have 1 attempt overall with 100% accuracy (since the attempt was correct)
	if accuracy := stats.GetSessionAccuracy(); accuracy != 100.0 {
		t.Errorf("Session accuracy should be 100.0 after 1 correct invalid attempt, got %f", accuracy)
	}
}

// Test session reset functionality
func TestResetSession(t *testing.T) {
	stats := New()

	// Add some attempts
	stats.RecordAttempt("hard", "weak", true)
	stats.RecordAttempt("soft", "strong", false)
	stats.RecordAttempt("pair", "medium", true)

	// Verify we have data
	if accuracy := stats.GetSessionAccuracy(); accuracy == 0.0 {
		t.Error("Should have non-zero accuracy before reset")
	}

	// Reset session
	stats.ResetSession()

	// Verify everything is reset
	if accuracy := stats.GetSessionAccuracy(); accuracy != 0.0 {
		t.Errorf("Session accuracy should be 0.0 after reset, got %f", accuracy)
	}

	categories := []string{"hard", "soft", "pair"}
	for _, category := range categories {
		if accuracy := stats.GetCategoryAccuracy(category); accuracy != 0.0 {
			t.Errorf("%s accuracy should be 0.0 after reset, got %f", category, accuracy)
		}
	}

	strengths := []string{"weak", "medium", "strong"}
	for _, strength := range strengths {
		if accuracy := stats.GetDealerStrengthAccuracy(strength); accuracy != 0.0 {
			t.Errorf("%s accuracy should be 0.0 after reset, got %f", strength, accuracy)
		}
	}
}
