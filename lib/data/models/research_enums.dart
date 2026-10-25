/// Scientific-method stage taxonomy — tune here without touching UI wiring (§11).
enum ResearchStage {
  question,
  background,
  hypothesis,
  method,
  evidence,
  analysis,
  conclusion,
  openQuestion,
  reference,
}

enum ItemType { text, link, image, video, file }

enum ClaimType { question, hypothesis, thesis }

enum ClaimStatus { open, supported, refuted, inconclusive }

enum Stance { supports, refutes, neutral }

enum Credibility { high, medium, low, unknown }

extension ResearchStageX on ResearchStage {
  String get label => switch (this) {
        ResearchStage.question => 'Question',
        ResearchStage.background => 'Background',
        ResearchStage.hypothesis => 'Hypothesis',
        ResearchStage.method => 'Method',
        ResearchStage.evidence => 'Evidence',
        ResearchStage.analysis => 'Analysis',
        ResearchStage.conclusion => 'Conclusion',
        ResearchStage.openQuestion => 'Open Questions',
        ResearchStage.reference => 'References',
      };

  String get shortLabel => switch (this) {
        ResearchStage.question => 'Q',
        ResearchStage.background => 'Bg',
        ResearchStage.hypothesis => 'H',
        ResearchStage.method => 'M',
        ResearchStage.evidence => 'Ev',
        ResearchStage.analysis => 'An',
        ResearchStage.conclusion => 'C',
        ResearchStage.openQuestion => 'OQ',
        ResearchStage.reference => 'Ref',
      };

  static const ordered = ResearchStage.values;
}
