import numpy as np
import pandas as pd

from scipy.stats import (
    chi2_contingency,
    ttest_ind,
    f_oneway,
    pearsonr,
    spearmanr
)


# ============================================================
# CATEGORICAL ANALYSIS
# ============================================================

def create_contingency_table(
        df,
        row_variable,
        column_variable
):
    """
    Create a contingency table for two categorical variables.

    Parameters
    ----------
    df : pandas.DataFrame
        Input dataframe.

    row_variable : str
        Variable displayed as rows.

    column_variable : str
        Variable displayed as columns.

    Returns
    -------
    pandas.DataFrame
        Observed frequency contingency table.
    """

    required_columns = {
        row_variable,
        column_variable
    }

    missing_columns = (
        required_columns -
        set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing columns: {missing_columns}"
        )

    return pd.crosstab(
        index=df[row_variable],
        columns=df[column_variable]
    )


def chi_square_test(contingency_table):
    """
    Perform a Chi-Square Test of Independence.

    Parameters
    ----------
    contingency_table : pandas.DataFrame
        Observed frequency table.

    Returns
    -------
    dict
        Chi-Square test results.
    """

    if not isinstance(
        contingency_table,
        pd.DataFrame
    ):
        raise TypeError(
            "contingency_table must be a pandas DataFrame."
        )

    if contingency_table.empty:
        raise ValueError(
            "contingency_table cannot be empty."
        )

    if (
        contingency_table.shape[0] < 2
        or contingency_table.shape[1] < 2
    ):
        raise ValueError(
            "Contingency table must contain at least "
            "2 rows and 2 columns."
        )

    chi2, p_value, dof, expected = chi2_contingency(
        contingency_table
    )

    expected = pd.DataFrame(
        expected,
        index=contingency_table.index,
        columns=contingency_table.columns
    )

    return {
        "chi2": round(chi2, 4),
        "p_value": p_value,
        "degrees_of_freedom": dof,
        "expected_frequencies": expected
    }


def cramers_v(contingency_table):
    """
    Calculate Cramér's V effect size.

    Parameters
    ----------
    contingency_table : pandas.DataFrame
        Observed frequency table.

    Returns
    -------
    dict
        Cramér's V and qualitative effect-size interpretation.
    """

    if not isinstance(
        contingency_table,
        pd.DataFrame
    ):
        raise TypeError(
            "contingency_table must be a pandas DataFrame."
        )

    if contingency_table.empty:
        raise ValueError(
            "contingency_table cannot be empty."
        )

    if (
        contingency_table.shape[0] < 2
        or contingency_table.shape[1] < 2
    ):
        raise ValueError(
            "Contingency table must contain at least "
            "2 rows and 2 columns."
        )

    chi2, _, _, _ = chi2_contingency(
        contingency_table
    )

    n = contingency_table.to_numpy().sum()

    k = min(contingency_table.shape)

    value = np.sqrt(
        chi2 / (n * (k - 1))
    )

    if value < 0.10:
        effect_size = "Negligible"

    elif value < 0.30:
        effect_size = "Weak"

    elif value < 0.50:
        effect_size = "Moderate"

    else:
        effect_size = "Strong"

    return {
        "cramers_v": round(value, 4),
        "effect_size": effect_size
    }


# ============================================================
# NUMERICAL ANALYSIS — TWO INDEPENDENT GROUPS
# ============================================================

def welch_t_test(
        df,
        numerical_variable,
        group_variable
):
    """
    Perform Welch's Independent Samples t-test.

    Welch's t-test is used to compare the means of
    two independent groups without assuming equal
    population variances.

    Parameters
    ----------
    df : pandas.DataFrame
        Input dataframe.

    numerical_variable : str
        Numerical variable being compared.

    group_variable : str
        Categorical variable defining the two groups.

    Returns
    -------
    dict
        Welch's t-test results.
    """

    required_columns = {
        numerical_variable,
        group_variable
    }

    missing_columns = (
        required_columns -
        set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing columns: {missing_columns}"
        )

    groups = (
        df[group_variable]
        .dropna()
        .unique()
    )

    if len(groups) != 2:
        raise ValueError(
            "Welch's t-test requires exactly "
            f"2 groups. Found {len(groups)}."
        )

    group_1 = df.loc[
        df[group_variable] == groups[0],
        numerical_variable
    ].dropna()

    group_2 = df.loc[
        df[group_variable] == groups[1],
        numerical_variable
    ].dropna()

    if len(group_1) < 2 or len(group_2) < 2:
        raise ValueError(
            "Each group must contain at least "
            "2 observations."
        )

    result = ttest_ind(
        group_1,
        group_2,
        equal_var=False
    )

    return {
        "group_1": groups[0],
        "group_2": groups[1],
        "group_1_count": len(group_1),
        "group_2_count": len(group_2),
        "group_1_mean": round(group_1.mean(), 4),
        "group_2_mean": round(group_2.mean(), 4),
        "t_statistic": round(result.statistic, 4),
        "p_value": result.pvalue,
        "degrees_of_freedom": round(result.df, 4)
    }


def cohens_d(
        df,
        numerical_variable,
        group_variable
):
    """
    Calculate Cohen's d effect size for two
    independent groups.

    Parameters
    ----------
    df : pandas.DataFrame
        Input dataframe.

    numerical_variable : str
        Numerical variable being compared.

    group_variable : str
        Categorical variable defining the two groups.

    Returns
    -------
    dict
        Cohen's d and qualitative effect-size interpretation.
    """

    required_columns = {
        numerical_variable,
        group_variable
    }

    missing_columns = (
        required_columns -
        set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing columns: {missing_columns}"
        )

    groups = (
        df[group_variable]
        .dropna()
        .unique()
    )

    if len(groups) != 2:
        raise ValueError(
            "Cohen's d requires exactly "
            f"2 groups. Found {len(groups)}."
        )

    group_1 = df.loc[
        df[group_variable] == groups[0],
        numerical_variable
    ].dropna()

    group_2 = df.loc[
        df[group_variable] == groups[1],
        numerical_variable
    ].dropna()

    n_1 = len(group_1)
    n_2 = len(group_2)

    if n_1 < 2 or n_2 < 2:
        raise ValueError(
            "Each group must contain at least "
            "2 observations."
        )

    sd_1 = group_1.std(ddof=1)
    sd_2 = group_2.std(ddof=1)

    pooled_sd = np.sqrt(
        (
            (n_1 - 1) * sd_1**2
            +
            (n_2 - 1) * sd_2**2
        )
        /
        (n_1 + n_2 - 2)
    )

    if pooled_sd == 0:
        raise ValueError(
            "Pooled standard deviation cannot be zero."
        )

    value = (
        group_1.mean() -
        group_2.mean()
    ) / pooled_sd

    absolute_value = abs(value)

    if absolute_value < 0.20:
        effect_size = "Negligible"

    elif absolute_value < 0.50:
        effect_size = "Small"

    elif absolute_value < 0.80:
        effect_size = "Moderate"

    else:
        effect_size = "Large"

    return {
        "group_1": groups[0],
        "group_2": groups[1],
        "cohens_d": round(value, 4),
        "effect_size": effect_size
    }


# ============================================================
# NUMERICAL ANALYSIS — MULTIPLE INDEPENDENT GROUPS
# ============================================================

def one_way_anova(
        df,
        numerical_variable,
        group_variable
):
    """
    Perform a One-Way ANOVA.

    Tests whether the means of three or more
    independent groups are statistically different.

    Parameters
    ----------
    df : pandas.DataFrame
        Input dataframe.

    numerical_variable : str
        Numerical variable being compared.

    group_variable : str
        Categorical variable defining the groups.

    Returns
    -------
    dict
        ANOVA test results.
    """

    required_columns = {
        numerical_variable,
        group_variable
    }

    missing_columns = (
        required_columns -
        set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing columns: {missing_columns}"
        )

    data = df[
        [numerical_variable, group_variable]
    ].dropna()

    groups = data[group_variable].unique()

    if len(groups) < 3:
        raise ValueError(
            "One-way ANOVA requires at least "
            "3 groups."
        )

    group_data = [
        data.loc[
            data[group_variable] == group,
            numerical_variable
        ]
        for group in groups
    ]

    if any(len(group) < 2 for group in group_data):
        raise ValueError(
            "Each group must contain at least "
            "2 observations."
        )

    result = f_oneway(*group_data)

    group_means = {
        group: round(
            data.loc[
                data[group_variable] == group,
                numerical_variable
            ].mean(),
            4
        )
        for group in groups
    }

    return {
        "groups": list(groups),
        "group_means": group_means,
        "f_statistic": round(result.statistic, 4),
        "p_value": result.pvalue
    }


def eta_squared(
        df,
        numerical_variable,
        group_variable
):
    """
    Calculate Eta Squared (η²) effect size for ANOVA.

    Eta squared represents the proportion of total
    variance in the numerical variable explained by
    the grouping variable.

    Parameters
    ----------
    df : pandas.DataFrame
        Input dataframe.

    numerical_variable : str
        Numerical variable being analyzed.

    group_variable : str
        Categorical variable defining the groups.

    Returns
    -------
    dict
        Eta squared and qualitative effect-size interpretation.
    """

    required_columns = {
        numerical_variable,
        group_variable
    }

    missing_columns = (
        required_columns -
        set(df.columns)
    )

    if missing_columns:
        raise ValueError(
            f"Missing columns: {missing_columns}"
        )

    data = df[
        [numerical_variable, group_variable]
    ].dropna()

    groups = data[group_variable].unique()

    if len(groups) < 3:
        raise ValueError(
            "Eta squared for this analysis requires "
            "at least 3 groups."
        )

    grand_mean = data[numerical_variable].mean()

    ss_between = sum(
        len(group_data) *
        (group_data[numerical_variable].mean() - grand_mean) ** 2
        for _, group_data in data.groupby(group_variable)
    )

    ss_total = (
        (
            data[numerical_variable] -
            grand_mean
        ) ** 2
    ).sum()

    if ss_total == 0:
        raise ValueError(
            "Total variance cannot be zero."
        )

    value = ss_between / ss_total

    if value < 0.01:
        effect_size = "Negligible"

    elif value < 0.06:
        effect_size = "Small"

    elif value < 0.14:
        effect_size = "Moderate"

    else:
        effect_size = "Large"

    return {
        "eta_squared": round(value, 4),
        "effect_size": effect_size
    }


# ============================================================
# CORRELATION ANALYSIS
# ============================================================

def pearson_correlation(
        x,
        y
):
    """
    Calculate Pearson correlation.

    Measures the strength and direction of a
    linear relationship between two numerical variables.

    Parameters
    ----------
    x : array-like
        First numerical variable.

    y : array-like
        Second numerical variable.

    Returns
    -------
    dict
        Pearson correlation coefficient and p-value.
    """

    x = pd.Series(x)
    y = pd.Series(y)

    valid = pd.concat(
        [x, y],
        axis=1
    ).dropna()

    if len(valid) < 3:
        raise ValueError(
            "At least 3 paired observations are required."
        )

    coefficient, p_value = pearsonr(
        valid.iloc[:, 0],
        valid.iloc[:, 1]
    )

    return {
        "correlation": round(coefficient, 4),
        "p_value": p_value
    }


def spearman_correlation(
        x,
        y
):
    """
    Calculate Spearman rank correlation.

    Measures the strength and direction of a
    monotonic relationship between two numerical
    or ordinal variables.

    Parameters
    ----------
    x : array-like
        First numerical or ordinal variable.

    y : array-like
        Second numerical or ordinal variable.

    Returns
    -------
    dict
        Spearman correlation coefficient and p-value.
    """

    x = pd.Series(x)
    y = pd.Series(y)

    valid = pd.concat(
        [x, y],
        axis=1
    ).dropna()

    if len(valid) < 3:
        raise ValueError(
            "At least 3 paired observations are required."
        )

    coefficient, p_value = spearmanr(
        valid.iloc[:, 0],
        valid.iloc[:, 1]
    )

    return {
        "correlation": round(coefficient, 4),
        "p_value": p_value
    }