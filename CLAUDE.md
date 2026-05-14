# CLAUDE.md — Data Science & Analytics Setup

**Role**: Data Scientist / Data Analyst / ML Engineer  
**Stack**: Python, SQL, pandas, DuckDB, Jupyter, data visualization  
**Updated**: 2026-05-14

---

## Principios Clave (Boris Cherny)

### 1. Plan Mode para Tareas No-Triviales
- Activar plan mode para cualquier cosa con 3+ pasos o decisiones arquitectónicas
- Si algo falla: **detener, replantear, no continuar**
- Usar planificación incluso para pasos de verificación
- Escribir especificaciones claras upfront

### 2. Verificación Antes de Marcar "Done"
- **Nunca** marcar tarea completa sin probar que funciona
- Ejecutar queries, revisar outputs, comparar resultados
- Tests deben pasar (si hay)
- Pregunta: "¿un staff data scientist aprobaría esto?"

### 3. Rastrear Progreso con TodoWrite
- Usar `TodoWrite` para todo lo no-trivial
- Marcar completa **inmediatamente** al terminar, no en batch
- Una sola tarea en `in_progress` a la vez

### 4. Mejoría Continua — Lessons.md
- Después de correcciones del usuario: actualizar `tasks/lessons.md`
- Capturar patrones que no funcionaron
- Próxima sesión: revisar lecciones relevantes

### 5. Autonomous Bug Fixing
- Con un reporte de bug: **solo arreglarlo**, sin pedir ayuda
- Seguir logs → errores → causa raíz
- Cero cambios de contexto

---

## Data Science Specific Rules

### SQL & Queries
- Prefer parameterized queries, never string concatenation for user input
- Expect large datasets (100M+ rows) — optimize for performance
- Use indexes, window functions, CTEs when needed
- Always include LIMIT or SAMPLE for exploration queries
- Document assumptions in query comments

### Python & Data Analysis
- Use pandas for dataframes, DuckDB for analytics queries
- Vectorize operations — avoid row-by-row loops
- Always check for NaN/NULL handling before analysis
- Document data assumptions (units, ranges, missing value strategy)
- Use type hints in functions

### Jupyter Notebooks
- Keep cells focused (one concern per cell)
- Output should be clear visualizations or summaries, not raw data dumps
- Save important findings to CSV/Parquet, not just in memory
- Don't commit notebook output/checkpoints to git

### Machine Learning
- Always split train/test/validation before building
- Document baseline metrics before optimization
- Cross-validate, don't rely on single split
- Feature importance should be explained, not just generated
- For class imbalance: mention strategy used (SMOTE, weights, etc)

### Data Visualization
- Default to matplotlib/seaborn, use plotly for interactive when needed
- Charts must have titles, axis labels, legends
- Use color-blind friendly palettes
- Don't show more than 5 series per chart (use subplots)

---

## Workflow

1. **Explore First** — understand data before modeling
   - Data profiling: dtypes, nulls, duplicates, outliers
   - Check distributions, cardinality
   - Identify target variable and features

2. **Document Assumptions** — data quality checks
   - What are expected ranges?
   - How to handle missing values?
   - Any known issues with this data?

3. **Build Incrementally**
   - Start simple (baseline model, basic EDA)
   - Add complexity only if justified by metrics
   - Version control both code and results

4. **Validate Results**
   - Check predictions make sense
   - Compare against baseline
   - Cross-validate
   - Test on holdout set

5. **Communicate Findings**
   - Visualize key insights
   - Quantify business impact
   - Document methodology for reproducibility

---

## Tools & Commands

### Python Environment
```bash
# Create venv (user should do this once)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Common packages
pip install pandas numpy scikit-learn matplotlib seaborn jupyterlab duckdb polars
```

### Jupyter
- Start: `jupyter lab`
- Always restart kernel between major changes
- Export results: `File > Export Notebook As > HTML`

### Git Workflow
- Branch per analysis/experiment
- Commit frequently with clear messages
- Don't commit data files, notebooks output, .venv/

---

## Session Checklist

- [ ] Know the business question upfront
- [ ] Check data quality before analysis
- [ ] Version control everything (except data)
- [ ] Document assumptions and methodology
- [ ] Validate results against baseline
- [ ] Create reproducible code (not one-off scripts)

---

## Mistakes to Avoid

❌ **Data Leakage**: fitting on train + test together  
❌ **Silent NaN**: not checking for missing values  
❌ **No Baseline**: jumping to complex models immediately  
❌ **Magic Numbers**: hardcoding thresholds without explanation  
❌ **Notebook Hell**: mixing exploration and production code  
❌ **No Reproducibility**: using random seeds without setting them  

---

## Learning & Improvement

- After each session, update this file with lessons learned
- If I make a common mistake: add it to the "Mistakes" section
- Track which tools/approaches worked best for your domain
- Monthly review: what patterns emerged?

Sources: [Boris Cherny's CLAUDE.md](https://gist.github.com/hqman/e29cb6386c539d795767e8c3fd2c959b) | [Claude Code Tips](https://medium.com/data-science-collective/10-claude-code-tips-from-the-creator-boris-cherny-36d5a8af2560)
