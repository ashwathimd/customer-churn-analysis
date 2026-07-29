import pandas as pd


def create_churn_summary(df, column):
    """
    Create a summary table showing customer count,
    churn count, retained count, and churn rate
    for a grouped feature.

    Parameters
    ----------
    df : pandas.DataFrame
        Customer churn dataset.

    column : str
        Column used for grouping.

    Returns
    -------
    pandas.DataFrame
        Summary table.
    """

    required_columns = {
        column,
        "Churn Value"
    }

    missing_columns = (
        required_columns
        - set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    summary = (
        df.groupby(column)
        .agg(
            customer_count=(column, "count"),
            churned=("Churn Value", "sum"),
        )
        .reset_index()
    )

    summary["retained"] = (
        summary["customer_count"]
        - summary["churned"]
    )

    summary["churn_rate"] = (
        summary["churned"]
        / summary["customer_count"]
        * 100
    ).round(2)

    return summary




def create_bivariate_churn_summary(
    df,
    column_1,
    column_2,
    TARGET = "Churn Value"
):
    required_columns = {
        column_1,
        column_2,
        TARGET 
    }

    missing_columns = (
        required_columns
        - set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    summary = (
        df.groupby([column_1, column_2])
        .agg(
            customer_count=("CustomerID", "count"),
            churned=(TARGET, "sum")
        )
        .reset_index()
    )

    summary["retained"] = (
        summary["customer_count"]
        - summary["churned"]
    )

    summary["churn_rate"] = (
        summary["churned"]
        / summary["customer_count"]
        * 100
    ).round(2)

    return summary



import pandas as pd


def create_segment_summary(
    df,
    grouping_columns,
    target_column="Churn Value",
    customer_column="CustomerID",
    min_customers=30,
    sort_by="churn_rate",
    ascending=False
):
    """
    Create a customer segment summary.

    Parameters
    ----------
    df : pandas.DataFrame
        Input dataframe.

    grouping_columns : list[str]
        Columns used to define customer segments.

    target_column : str, default="Churn Value"
        Binary target column.

    customer_column : str, default="CustomerID"
        Unique customer identifier.

    min_customers : int, default=30
        Minimum number of customers required for a
        segment to be included.

    sort_by : str or list[str], default="churn_rate"
        Column(s) used to sort the results.

    ascending : bool or list[bool], default=False
        Sort order corresponding to sort_by.

    Returns
    -------
    pandas.DataFrame
        Customer segment summary.
    """

    # -----------------------------
    # Validate required columns
    # -----------------------------
    required_columns = (
        set(grouping_columns)
        | {customer_column, target_column}
    )

    missing_columns = (
        required_columns
        - set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {missing_columns}"
        )

    # -----------------------------
    # Create summary
    # -----------------------------
    summary = (
        df.groupby(grouping_columns)
        .agg(
            customer_count=(customer_column, "count"),
            churned=(target_column, "sum")
        )
        .reset_index()
    )

    # -----------------------------
    # Calculate metrics
    # -----------------------------
    summary["retained"] = (
        summary["customer_count"]
        - summary["churned"]
    )

    summary["churn_rate"] = (
        summary["churned"]
        / summary["customer_count"]
        * 100
    ).round(2)

    # -----------------------------
    # Filter small segments
    # -----------------------------
    summary = (
        summary[
            summary["customer_count"] >= min_customers
        ]
        .copy()
    )

    # -----------------------------
    # Validate sort column(s)
    # -----------------------------
    valid_sort_columns = {
        "customer_count",
        "churned",
        "retained",
        "churn_rate"
    }

    if isinstance(sort_by, str):
        sort_by = [sort_by]

    if isinstance(ascending, bool):
        ascending = [ascending] * len(sort_by)

    invalid_columns = (
        set(sort_by)
        - valid_sort_columns
    )

    if invalid_columns:
        raise ValueError(
            f"Invalid sort column(s): {invalid_columns}"
        )

    if len(sort_by) != len(ascending):
        raise ValueError(
            "sort_by and ascending must have the same length."
        )

    # -----------------------------
    # Sort results
    # -----------------------------
    summary = (
        summary.sort_values(
            by=sort_by,
            ascending=ascending
        )
        .reset_index(drop=True)
    )

    return summary