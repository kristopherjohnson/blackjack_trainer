#pragma once

#include "stats.h"
#include "strategy.h"
#include <memory>
#include <string>
#include <vector>

namespace blackjack {

/**
 * Base class for all training session types.
 */
class TrainingSession {
public:
  explicit TrainingSession(const std::string &difficulty = "normal");
  virtual ~TrainingSession() = default;

  /**
   * Return the mode name for display purposes.
   */
  virtual std::string get_mode_name() const = 0;

  /**
   * Return the maximum number of questions for this session type.
   */
  virtual int get_max_questions() const = 0;

  /**
   * Generate a scenario for this training mode.
   * @return Tuple of (hand_type, player_cards, player_total, dealer_card)
   */
  virtual std::tuple<std::string, std::vector<int>, int, int>
  generate_scenario() = 0;

  /**
   * Run the training session.
   * @param stats Statistics object to track performance
   */
  void run(Statistics &stats);

protected:
  /**
   * Setup the session. Override in subclasses if additional setup is needed.
   * @return True if setup successful, false if user cancelled
   */
  virtual bool setup_session();

  /**
   * Helper method to generate card representation for a hand.
   */
  std::vector<int> generate_hand_cards(const std::string &hand_type,
                                       int player_total) const;

  /**
   * Check if user's action matches the correct action.
   */
  bool check_answer(char user_action, char correct_action) const;

  /**
   * Display feedback for the user's answer.
   * @return Pair of (correct, quit_requested)
   */
  std::pair<bool, bool> show_feedback(
      const std::tuple<std::string, std::vector<int>, int, int> &scenario,
      char user_action, char correct_action) const;

  std::string difficulty_;
  std::unique_ptr<StrategyChart> strategy_;
  int correct_count_;
  int total_count_;
};

/**
 * Random practice session with all hand types and dealer cards.
 */
class RandomTrainingSession : public TrainingSession {
public:
  explicit RandomTrainingSession(const std::string &difficulty = "normal");

  std::string get_mode_name() const override;
  int get_max_questions() const override;
  std::tuple<std::string, std::vector<int>, int, int>
  generate_scenario() override;
};

/**
 * Training session focused on specific dealer strength groups.
 */
class DealerGroupTrainingSession : public TrainingSession {
public:
  explicit DealerGroupTrainingSession(const std::string &difficulty = "normal");

  std::string get_mode_name() const override;
  int get_max_questions() const override;
  std::tuple<std::string, std::vector<int>, int, int>
  generate_scenario() override;

protected:
  bool setup_session() override;

private:
  int dealer_group_;
};

/**
 * Training session focused on specific hand types.
 */
class HandTypeTrainingSession : public TrainingSession {
public:
  explicit HandTypeTrainingSession(const std::string &difficulty = "normal");

  std::string get_mode_name() const override;
  int get_max_questions() const override;
  std::tuple<std::string, std::vector<int>, int, int>
  generate_scenario() override;

protected:
  bool setup_session() override;

private:
  int hand_type_choice_;
};

/**
 * Training session focused on absolute rules (always/never scenarios).
 */
class AbsoluteTrainingSession : public TrainingSession {
public:
  explicit AbsoluteTrainingSession(const std::string &difficulty = "normal");

  std::string get_mode_name() const override;
  int get_max_questions() const override;
  std::tuple<std::string, std::vector<int>, int, int>
  generate_scenario() override;
};

} // namespace blackjack