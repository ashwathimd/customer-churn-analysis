import matplotlib.pyplot as plt
import seaborn as sns


def plot_churn_rate_bar(
    summary_df,
    group_column,
    figsize=(6, 4)
):
    """
    Plot customer churn rate for a grouped feature.

    Parameters
    ----------
    summary_df : pandas.DataFrame
        Output from create_churn_summary().

    group_column : str
        Grouping column.

    figsize : tuple, default=(6, 4)
        Figure size.
    """

    required_columns = {
        group_column,
        "churn_rate"
    }

    missing_columns = (
        required_columns
        - set(summary_df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    plt.figure(figsize=figsize)

    ax = sns.barplot(
        data=summary_df,
        x=group_column,
        y="churn_rate"
    )

    for container in ax.containers:
        ax.bar_label(
            container,
            fmt="%.2f%%"
        )

    plt.title(
        f"Customer Churn Rate by {group_column}"
    )
    plt.xlabel(group_column)
    plt.ylabel("Churn Rate (%)")

    plt.tight_layout()
    plt.show()


import matplotlib.pyplot as plt
import seaborn as sns


def plot_bivariate_churn_rate(
    summary_df,
    x,
    hue,
    figsize=(10, 5)
):

    required_columns = {
        x,
        hue,
        "churn_rate"
    }

    missing_columns = (
        required_columns
        - set(summary_df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    plt.figure(figsize=(10,5))

    ax = sns.barplot(
        data=summary_df,
        x=x,
        y="churn_rate",
        hue=hue
    )

    for container in ax.containers:
        ax.bar_label(
            container,
            fmt="%.2f%%",
            padding=2
        )

    plt.title(
        f"Customer Churn Rate by {x} and {hue}"
    )

    plt.xlabel(x)
    plt.ylabel("Churn Rate (%)")

    plt.legend(title=hue)

    plt.tight_layout()

    plt.show()


import matplotlib.pyplot as plt
import seaborn as sns


def plot_top_segments(
    summary_df,
    grouping_columns,
    top_n=10,
    figsize=(12, 6)
):
    """
    Plot the top customer segments ranked by churn rate.
    """

    plot_df = summary_df.head(top_n).copy()

    plot_df["Segment"] = (
        plot_df[grouping_columns]
        .astype(str)
        .agg(" | ".join, axis=1)
    )

    plt.figure(figsize=figsize)

    ax = sns.barplot(
        data=plot_df,
        x="churn_rate",
        y="Segment"
    )

    for container in ax.containers:
        ax.bar_label(
            container,
            fmt="%.2f%%",
            padding=3
        )

    plt.title(
        f"Top {top_n} Customer Segments by Churn Rate"
    )

    plt.xlabel("Churn Rate (%)")
    plt.ylabel("Customer Segment")

    plt.tight_layout()
    plt.show()