import math

def interest_rate_per_second_accurate(APY):
    seconds_per_year = 31_556_925  # Mean tropical year in seconds
    return (1 + APY / 100) ** (1 / seconds_per_year) - 1

# Calculate for 100% APY
APY_100 = 100
r_second_100_percent_accurate = interest_rate_per_second_accurate(APY_100)
base_unit_interest_rate_100_percent_accurate = r_second_100_percent_accurate * 1e18

# Calculate for 10% APY
APY_10 = 10
r_second_10_percent_accurate = interest_rate_per_second_accurate(APY_10)
base_unit_interest_rate_10_percent_accurate = r_second_10_percent_accurate * 1e18

# Calculate for 10000% APY
APY_10000 = 10000
r_second_10000_percent_accurate = interest_rate_per_second_accurate(APY_10000)
base_unit_interest_rate_10000_percent_accurate = r_second_10000_percent_accurate * 1e18

print("Interest rate per second for 100% APY, scaled by 1e18:", base_unit_interest_rate_100_percent_accurate)
print("Interest rate per second for 10% APY, scaled by 1e18:", base_unit_interest_rate_10_percent_accurate)
print("Interest rate per second for 10000% APY, scaled by 1e18:", base_unit_interest_rate_10000_percent_accurate)

