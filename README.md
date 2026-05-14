# Data Science Project

## Setup

1. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start Jupyter**
   ```bash
   jupyter lab
   ```

## Project Structure

```
├── data/
│   ├── raw/           # Original data (don't modify)
│   └── processed/     # Cleaned data
├── notebooks/         # Jupyter notebooks for exploration
├── src/               # Python modules and functions
├── models/            # Trained model files
├── results/           # Outputs, visualizations, reports
└── CLAUDE.md          # AI context (update as needed)
```

## Workflow

1. **Explore** (notebooks) → understand data
2. **Process** (src scripts) → clean and prepare
3. **Model** (notebooks) → train and validate
4. **Report** (results) → visualize findings

## Key Rules

- Don't commit large data files or models
- Keep notebooks for exploration, src/ for reusable code
- Always set random seeds for reproducibility
- Document assumptions and methodology

See CLAUDE.md for detailed guidelines.
