# Analyse de Sensibilité aux Facteurs Macroéconomiques des Entreprises Financières

Ce dépôt contient le code et la documentation pour l'analyse des sensibilités aux facteurs macroéconomiques des entreprises financières et bancaires américaines. L'analyse utilise la première étape du modèle d'évaluation d'actifs en deux étapes de Fama-MacBeth pour estimer les sensibilités au niveau de l'entreprise aux principaux facteurs macroéconomiques.

## Aperçu du Projet

L'étude analyse 316 entreprises financières et bancaires américaines cotées en bourse de 2001 à 2025, en se concentrant sur leur sensibilité à :
- L'inflation
- Les écarts de crédit
- La croissance du PIB

L'analyse produit un score de résilience macroéconomique conçu pour identifier les entreprises mieux positionnées pour résister aux conditions macroéconomiques défavorables.

## Structure du Dépôt

```
project_files/
├── clean_data.R
├── clean_data_2.R
├── data_analysis.R
├── scoring.R
├── wrds.R
└── README_FR.md
```

## Exigences en Matière de Données

Pour reproduire cette analyse, vous aurez besoin d'accéder à :

1. WRDS (Wharton Research Data Services)
   - Base de données CRSP pour les rendements boursiers
   - Base de données Compustat pour les données financières des entreprises
   - Codes SIC requis : 6000-6300 (Services Financiers)

2. API FRED
   - Séries temporelles macroéconomiques
   - Clé API requise

3. Données Historiques du S&P 500
   - Données de prix quotidiennes
   - Disponibles auprès de divers fournisseurs de données financières

## Installation et Configuration

1. Cloner ce dépôt :
   ```bash
   git clone https://github.com/erobertson753/macro_sensitivity_analysis.git
   ```

2. Installer les packages R requis :
   ```R
   install.packages(c("dplyr", "tidyr", "purrr", "plm", "broom", "RPostgres", "tidyverse", "lubridate", "zoo"))
   ```

3. Installer les packages Python requis :
   ```bash
   pip install pandas numpy requests
   ```

4. Configurer les variables d'environnement :
   - Nom d'utilisateur et mot de passe WRDS
   - Clé API FRED
   - Paramètres de connexion à la base de données

## Pipeline de Traitement des Données

1. Extraire les données de WRDS en utilisant `wrds.R`
2. Nettoyer et traiter les données en utilisant `clean_data.R` et `clean_data_2.R`
3. Effectuer l'analyse en utilisant `data_analysis.R`
4. Générer les scores en utilisant `scoring.R`

## Reproduction des Résultats

Pour reproduire l'analyse :

1. Assurez-vous d'avoir accès à toutes les sources de données requises
2. Exécutez les scripts dans l'ordre suivant :
   ```bash
   Rscript wrds.R
   Rscript clean_data.R
   Rscript clean_data_2.R
   Rscript data_analysis.R
   Rscript scoring.R
   ```

## Fichiers de Sortie

L'analyse génère plusieurs fichiers de sortie clés :
- Résultats de régression
- Estimations de sensibilité au niveau de l'entreprise
- Scores de résilience macroéconomique
- Statistiques sommaires

## Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.

## Remerciements

- WRDS pour l'accès aux données CRSP et Compustat
- FRED pour les données macroéconomiques
- Fama et MacBeth pour leur travail fondateur en évaluation d'actifs

## Contact

Pour toute question ou commentaire, veuillez contacter l'auteur à [your-email@example.com](mailto:your-email@example.com) 
