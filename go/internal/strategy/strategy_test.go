package strategy

import (
	"testing"
)

// Test hard totals low values (5-8) should always hit
func TestHardTotalsLowValues(t *testing.T) {
	chart := New()

	for total := 5; total <= 8; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("hard", total, dealer)
			if action != 'H' {
				t.Errorf("Hard %d vs %d: expected H, got %c", total, dealer, action)
			}
		}
	}
}

// Test hard 9 strategy: Double vs 3-6, otherwise hit
func TestHard9Strategy(t *testing.T) {
	chart := New()

	// Should double vs 3-6
	for dealer := 3; dealer <= 6; dealer++ {
		action := chart.GetCorrectAction("hard", 9, dealer)
		if action != 'D' {
			t.Errorf("Hard 9 vs %d: expected D, got %c", dealer, action)
		}
	}

	// Should hit vs 2, 7-A
	hitDealers := []int{2, 7, 8, 9, 10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("hard", 9, dealer)
		if action != 'H' {
			t.Errorf("Hard 9 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test hard 10 strategy: Double vs 2-9, otherwise hit
func TestHard10Strategy(t *testing.T) {
	chart := New()

	// Should double vs 2-9
	for dealer := 2; dealer <= 9; dealer++ {
		action := chart.GetCorrectAction("hard", 10, dealer)
		if action != 'D' {
			t.Errorf("Hard 10 vs %d: expected D, got %c", dealer, action)
		}
	}

	// Should hit vs 10, A
	hitDealers := []int{10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("hard", 10, dealer)
		if action != 'H' {
			t.Errorf("Hard 10 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test hard 11 strategy: Double vs 2-10, hit vs A
func TestHard11Strategy(t *testing.T) {
	chart := New()

	// Should double vs 2-10
	for dealer := 2; dealer <= 10; dealer++ {
		action := chart.GetCorrectAction("hard", 11, dealer)
		if action != 'D' {
			t.Errorf("Hard 11 vs %d: expected D, got %c", dealer, action)
		}
	}

	// Should hit vs A
	action := chart.GetCorrectAction("hard", 11, 11)
	if action != 'H' {
		t.Errorf("Hard 11 vs A: expected H, got %c", action)
	}
}

// Test hard 12 strategy: Stand vs 4-6, otherwise hit
func TestHard12Strategy(t *testing.T) {
	chart := New()

	// Should stand vs 4-6
	for dealer := 4; dealer <= 6; dealer++ {
		action := chart.GetCorrectAction("hard", 12, dealer)
		if action != 'S' {
			t.Errorf("Hard 12 vs %d: expected S, got %c", dealer, action)
		}
	}

	// Should hit vs 2-3, 7-A
	hitDealers := []int{2, 3, 7, 8, 9, 10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("hard", 12, dealer)
		if action != 'H' {
			t.Errorf("Hard 12 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test hard 13-16 strategy: Stand vs 2-6, otherwise hit
func TestHard13To16Strategy(t *testing.T) {
	chart := New()

	for total := 13; total <= 16; total++ {
		// Should stand vs 2-6
		for dealer := 2; dealer <= 6; dealer++ {
			action := chart.GetCorrectAction("hard", total, dealer)
			if action != 'S' {
				t.Errorf("Hard %d vs %d: expected S, got %c", total, dealer, action)
			}
		}

		// Should hit vs 7-A
		for dealer := 7; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("hard", total, dealer)
			if action != 'H' {
				t.Errorf("Hard %d vs %d: expected H, got %c", total, dealer, action)
			}
		}
	}
}

// Test hard 17+ strategy: Always stand
func TestHard17PlusStrategy(t *testing.T) {
	chart := New()

	for total := 17; total <= 21; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("hard", total, dealer)
			if action != 'S' {
				t.Errorf("Hard %d vs %d: expected S, got %c", total, dealer, action)
			}
		}
	}
}

// Test soft 13-14 strategy: Double vs 5-6, otherwise hit
func TestSoft13To14Strategy(t *testing.T) {
	chart := New()

	for _, total := range []int{13, 14} {
		// Should double vs 5-6
		for dealer := 5; dealer <= 6; dealer++ {
			action := chart.GetCorrectAction("soft", total, dealer)
			if action != 'D' {
				t.Errorf("Soft %d vs %d: expected D, got %c", total, dealer, action)
			}
		}

		// Should hit vs others
		hitDealers := []int{2, 3, 4, 7, 8, 9, 10, 11}
		for _, dealer := range hitDealers {
			action := chart.GetCorrectAction("soft", total, dealer)
			if action != 'H' {
				t.Errorf("Soft %d vs %d: expected H, got %c", total, dealer, action)
			}
		}
	}
}

// Test soft 15-16 strategy: Double vs 4-6, otherwise hit
func TestSoft15To16Strategy(t *testing.T) {
	chart := New()

	for _, total := range []int{15, 16} {
		// Should double vs 4-6
		for dealer := 4; dealer <= 6; dealer++ {
			action := chart.GetCorrectAction("soft", total, dealer)
			if action != 'D' {
				t.Errorf("Soft %d vs %d: expected D, got %c", total, dealer, action)
			}
		}

		// Should hit vs others
		hitDealers := []int{2, 3, 7, 8, 9, 10, 11}
		for _, dealer := range hitDealers {
			action := chart.GetCorrectAction("soft", total, dealer)
			if action != 'H' {
				t.Errorf("Soft %d vs %d: expected H, got %c", total, dealer, action)
			}
		}
	}
}

// Test soft 17 strategy: Double vs 3-6, otherwise hit
func TestSoft17Strategy(t *testing.T) {
	chart := New()

	// Should double vs 3-6
	for dealer := 3; dealer <= 6; dealer++ {
		action := chart.GetCorrectAction("soft", 17, dealer)
		if action != 'D' {
			t.Errorf("Soft 17 vs %d: expected D, got %c", dealer, action)
		}
	}

	// Should hit vs others
	hitDealers := []int{2, 7, 8, 9, 10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("soft", 17, dealer)
		if action != 'H' {
			t.Errorf("Soft 17 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test soft 18 strategy: Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
func TestSoft18Strategy(t *testing.T) {
	chart := New()

	// Should stand vs 2, 7, 8
	standDealers := []int{2, 7, 8}
	for _, dealer := range standDealers {
		action := chart.GetCorrectAction("soft", 18, dealer)
		if action != 'S' {
			t.Errorf("Soft 18 vs %d: expected S, got %c", dealer, action)
		}
	}

	// Should double vs 3-6
	for dealer := 3; dealer <= 6; dealer++ {
		action := chart.GetCorrectAction("soft", 18, dealer)
		if action != 'D' {
			t.Errorf("Soft 18 vs %d: expected D, got %c", dealer, action)
		}
	}

	// Should hit vs 9, 10, A
	hitDealers := []int{9, 10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("soft", 18, dealer)
		if action != 'H' {
			t.Errorf("Soft 18 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test soft 19+ strategy: Always stand
func TestSoft19PlusStrategy(t *testing.T) {
	chart := New()

	for _, total := range []int{19, 20, 21} {
		for dealer := 2; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("soft", total, dealer)
			if action != 'S' {
				t.Errorf("Soft %d vs %d: expected S, got %c", total, dealer, action)
			}
		}
	}
}

// Test pairs A,A strategy: Always split
func TestPairsAcesStrategy(t *testing.T) {
	chart := New()

	for dealer := 2; dealer <= 11; dealer++ {
		action := chart.GetCorrectAction("pair", 11, dealer)
		if action != 'Y' {
			t.Errorf("A,A vs %d: expected Y, got %c", dealer, action)
		}
	}
}

// Test pairs 2,2 and 3,3 strategy: Split vs 2-7, otherwise hit
func TestPairs2And3Strategy(t *testing.T) {
	chart := New()

	for _, pairVal := range []int{2, 3} {
		// Should split vs 2-7
		for dealer := 2; dealer <= 7; dealer++ {
			action := chart.GetCorrectAction("pair", pairVal, dealer)
			if action != 'Y' {
				t.Errorf("%d,%d vs %d: expected Y, got %c", pairVal, pairVal, dealer, action)
			}
		}

		// Should hit vs 8-A
		for dealer := 8; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("pair", pairVal, dealer)
			if action != 'H' {
				t.Errorf("%d,%d vs %d: expected H, got %c", pairVal, pairVal, dealer, action)
			}
		}
	}
}

// Test pairs 4,4 strategy: Split vs 5-6, otherwise hit
func TestPairs4Strategy(t *testing.T) {
	chart := New()

	// Should split vs 5-6
	for dealer := 5; dealer <= 6; dealer++ {
		action := chart.GetCorrectAction("pair", 4, dealer)
		if action != 'Y' {
			t.Errorf("4,4 vs %d: expected Y, got %c", dealer, action)
		}
	}

	// Should hit vs others
	hitDealers := []int{2, 3, 4, 7, 8, 9, 10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("pair", 4, dealer)
		if action != 'H' {
			t.Errorf("4,4 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test pairs 5,5 strategy: Never split, treat as hard 10
func TestPairs5Strategy(t *testing.T) {
	chart := New()

	// Should double vs 2-9
	for dealer := 2; dealer <= 9; dealer++ {
		action := chart.GetCorrectAction("pair", 5, dealer)
		if action != 'D' {
			t.Errorf("5,5 vs %d: expected D, got %c", dealer, action)
		}
	}

	// Should hit vs 10, A
	hitDealers := []int{10, 11}
	for _, dealer := range hitDealers {
		action := chart.GetCorrectAction("pair", 5, dealer)
		if action != 'H' {
			t.Errorf("5,5 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test pairs 6,6 strategy: Split vs 2-6, otherwise hit
func TestPairs6Strategy(t *testing.T) {
	chart := New()

	// Should split vs 2-6
	for dealer := 2; dealer <= 6; dealer++ {
		action := chart.GetCorrectAction("pair", 6, dealer)
		if action != 'Y' {
			t.Errorf("6,6 vs %d: expected Y, got %c", dealer, action)
		}
	}

	// Should hit vs 7-A
	for dealer := 7; dealer <= 11; dealer++ {
		action := chart.GetCorrectAction("pair", 6, dealer)
		if action != 'H' {
			t.Errorf("6,6 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test pairs 7,7 strategy: Split vs 2-7, otherwise hit
func TestPairs7Strategy(t *testing.T) {
	chart := New()

	// Should split vs 2-7
	for dealer := 2; dealer <= 7; dealer++ {
		action := chart.GetCorrectAction("pair", 7, dealer)
		if action != 'Y' {
			t.Errorf("7,7 vs %d: expected Y, got %c", dealer, action)
		}
	}

	// Should hit vs 8-A
	for dealer := 8; dealer <= 11; dealer++ {
		action := chart.GetCorrectAction("pair", 7, dealer)
		if action != 'H' {
			t.Errorf("7,7 vs %d: expected H, got %c", dealer, action)
		}
	}
}

// Test pairs 8,8 strategy: Always split
func TestPairs8Strategy(t *testing.T) {
	chart := New()

	for dealer := 2; dealer <= 11; dealer++ {
		action := chart.GetCorrectAction("pair", 8, dealer)
		if action != 'Y' {
			t.Errorf("8,8 vs %d: expected Y, got %c", dealer, action)
		}
	}
}

// Test pairs 9,9 strategy: Split vs 2-9 except 7, stand vs 7,10,A
func TestPairs9Strategy(t *testing.T) {
	chart := New()

	// Should split vs 2-6, 8-9
	splitDealers := []int{2, 3, 4, 5, 6, 8, 9}
	for _, dealer := range splitDealers {
		action := chart.GetCorrectAction("pair", 9, dealer)
		if action != 'Y' {
			t.Errorf("9,9 vs %d: expected Y, got %c", dealer, action)
		}
	}

	// Should stand vs 7, 10, A
	standDealers := []int{7, 10, 11}
	for _, dealer := range standDealers {
		action := chart.GetCorrectAction("pair", 9, dealer)
		if action != 'S' {
			t.Errorf("9,9 vs %d: expected S, got %c", dealer, action)
		}
	}
}

// Test pairs 10,10 strategy: Never split, always stand
func TestPairs10Strategy(t *testing.T) {
	chart := New()

	for dealer := 2; dealer <= 11; dealer++ {
		action := chart.GetCorrectAction("pair", 10, dealer)
		if action != 'S' {
			t.Errorf("10,10 vs %d: expected S, got %c", dealer, action)
		}
	}
}

// Test all hard totals coverage
func TestAllHardTotalsCoverage(t *testing.T) {
	chart := New()

	for total := 5; total <= 21; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("hard", total, dealer)
			if action != 'H' && action != 'S' && action != 'D' {
				t.Errorf("Hard %d vs %d: invalid action %c", total, dealer, action)
			}
		}
	}
}

// Test all soft totals coverage
func TestAllSoftTotalsCoverage(t *testing.T) {
	chart := New()

	for total := 13; total <= 21; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("soft", total, dealer)
			if action != 'H' && action != 'S' && action != 'D' {
				t.Errorf("Soft %d vs %d: invalid action %c", total, dealer, action)
			}
		}
	}
}

// Test all pairs coverage
func TestAllPairsCoverage(t *testing.T) {
	chart := New()

	pairValues := []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
	for _, pairVal := range pairValues {
		for dealer := 2; dealer <= 11; dealer++ {
			action := chart.GetCorrectAction("pair", pairVal, dealer)
			if action != 'H' && action != 'S' && action != 'D' && action != 'Y' {
				t.Errorf("Pair %d,%d vs %d: invalid action %c", pairVal, pairVal, dealer, action)
			}
		}
	}
}

// Test edge cases
func TestEdgeCases(t *testing.T) {
	chart := New()

	// Test invalid hand type
	action := chart.GetCorrectAction("invalid", 16, 10)
	if action != 'H' {
		t.Errorf("Invalid hand type should default to H, got %c", action)
	}

	// Test boundary values
	action = chart.GetCorrectAction("hard", 4, 2) // Below normal range
	if action != 'H' {
		t.Errorf("Hard 4 vs 2 should default to H, got %c", action)
	}
}

// Test absolute rules
func TestAbsoluteRules(t *testing.T) {
	chart := New()

	// Test pair absolutes
	if !chart.IsAbsoluteRule("pair", 11, 5) { // A,A
		t.Error("A,A should be absolute rule")
	}
	if !chart.IsAbsoluteRule("pair", 8, 5) { // 8,8
		t.Error("8,8 should be absolute rule")
	}
	if !chart.IsAbsoluteRule("pair", 10, 5) { // 10,10
		t.Error("10,10 should be absolute rule")
	}
	if !chart.IsAbsoluteRule("pair", 5, 5) { // 5,5
		t.Error("5,5 should be absolute rule")
	}

	// Test hard absolutes
	if !chart.IsAbsoluteRule("hard", 17, 5) {
		t.Error("Hard 17+ should be absolute rule")
	}
	if !chart.IsAbsoluteRule("hard", 20, 5) {
		t.Error("Hard 20 should be absolute rule")
	}

	// Test soft absolutes
	if !chart.IsAbsoluteRule("soft", 19, 5) {
		t.Error("Soft 19+ should be absolute rule")
	}
	if !chart.IsAbsoluteRule("soft", 20, 5) {
		t.Error("Soft 20 should be absolute rule")
	}

	// Test non-absolutes
	if chart.IsAbsoluteRule("hard", 16, 5) {
		t.Error("Hard 16 should not be absolute rule")
	}
	if chart.IsAbsoluteRule("soft", 18, 5) {
		t.Error("Soft 18 should not be absolute rule")
	}
}

// Test dealer groups
func TestDealerGroups(t *testing.T) {
	chart := New()
	groups := chart.GetDealerGroups()

	// Check weak cards
	weak, exists := groups["weak"]
	if !exists {
		t.Error("Weak dealer group should exist")
	}
	expectedWeak := []int{4, 5, 6}
	if len(weak) != len(expectedWeak) {
		t.Errorf("Weak group length: expected %d, got %d", len(expectedWeak), len(weak))
	}

	// Check medium cards
	medium, exists := groups["medium"]
	if !exists {
		t.Error("Medium dealer group should exist")
	}
	expectedMedium := []int{2, 3, 7, 8}
	if len(medium) != len(expectedMedium) {
		t.Errorf("Medium group length: expected %d, got %d", len(expectedMedium), len(medium))
	}

	// Check strong cards
	strong, exists := groups["strong"]
	if !exists {
		t.Error("Strong dealer group should exist")
	}
	expectedStrong := []int{9, 10, 11}
	if len(strong) != len(expectedStrong) {
		t.Errorf("Strong group length: expected %d, got %d", len(expectedStrong), len(strong))
	}
}

// Test explanations
func TestExplanations(t *testing.T) {
	chart := New()

	// Test specific explanations
	explanation := chart.GetExplanation("pair", 11, 5) // A,A
	if explanation == "" {
		t.Error("A,A should have explanation")
	}

	explanation = chart.GetExplanation("pair", 8, 5) // 8,8
	if explanation == "" {
		t.Error("8,8 should have explanation")
	}

	explanation = chart.GetExplanation("soft", 18, 5) // A,7
	if explanation == "" {
		t.Error("Soft 18 should have explanation")
	}

	// Test dealer strength explanations
	explanation = chart.GetExplanation("hard", 16, 5) // vs weak dealer
	if explanation == "" {
		t.Error("Should have explanation for weak dealer")
	}

	explanation = chart.GetExplanation("hard", 16, 10) // vs strong dealer
	if explanation == "" {
		t.Error("Should have explanation for strong dealer vs teens")
	}
}
