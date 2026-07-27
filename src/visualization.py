import matplotlib.pyplot as plt
import seaborn as sns


def categorical_churn_plot(summary_df, column):
    required_columns = {column, "Churn_Rate"}

    missing = required_columns - set(summary_df.columns)

    if missing:
        raise ValueError(
        f"Missing required columns: {missing}"
    )
    """
    Plot churn rate for a categorical feature.

    Parameters
    ----------
    summary_df : pandas.DataFrame
        Output from analyze_categorical().

    column : str
        Name of the categorical feature.
    """

    plt.figure(figsize=(6, 4))

    ax = sns.barplot(
        data=summary_df,
        x=column,
        y="Churn_Rate"
    )

    for container in ax.containers:
        ax.bar_label(container, fmt="%.2f%%")

    plt.title(f"Customer Churn Rate by {column}")
    plt.xlabel(column)
    plt.ylabel("Churn Rate (%)")

    plt.tight_layout()
    plt.show()