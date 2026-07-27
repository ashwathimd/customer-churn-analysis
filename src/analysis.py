import pandas as pd

TARGET = "Churn Value"


def analyze_categorical(df, column):
    """
    Analyze churn for a categorical feature.

    Parameters
    ----------
    df : pandas.DataFrame
        Cleaned customer churn dataset.

    column : str
        Categorical feature to analyze.

    Returns
    -------
    pandas.DataFrame
        Summary table with customer count, churn count,
        retained count, and churn rate.
    """

    if column not in df.columns:
        raise ValueError(f"{column} is not a valid column.")

    summary_df = (
        df.groupby(column)
          .agg(
              Customer_Count=(column, "count"),
              Churned=(TARGET, "sum"),
              Churn_Rate=(TARGET, "mean")
          )
    )

    summary_df["Retained"] = (
        summary_df["Customer_Count"]
        - summary_df["Churned"]
    )

    summary_df["Churn_Rate"] = (
        summary_df["Churn_Rate"]
        .mul(100)
        .round(2)
    )

    summary_df = summary_df.reset_index()

    return summary_df