# Spotify Data Pipeline & Recommendation System

## Summary

This project is a data pipeline and recommendation system for Spotify. It is built using Python, PostgreSQL, dbt, and AWS services.  This is still a work in progress.

<p align="center">
    <img src="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54" alt="Python">
    <img src="https://img.shields.io/badge/pandas-%23150458.svg?style=for-the-badge&logo=pandas&logoColor=white" alt="Pandas">
    <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
    <img src="https://img.shields.io/badge/pgAdmin-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="pgAdmin">
    <img src="https://img.shields.io/badge/AWS%20EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" alt="EC2">
    <img src="https://img.shields.io/badge/AWS%20S3-569A31?style=for-the-badge&logo=amazonaws&logoColor=white" alt="S3">
    <img src="https://img.shields.io/badge/dbt-F14336?style=for-the-badge&logo=dbt&logoColor=white" alt="dbt">
    <img src="https://img.shields.io/badge/AWS%20Lambda-F90?style=for-the-badge&logo=aws-lambda&logoColor=white" alt="Lambda">
    <img src="https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
    <img src="https://img.shields.io/badge/Spotify%20API-1DB954?style=for-the-badge&logo=spotify&logoColor=white" alt="Spotify API">
    <img src="https://img.shields.io/badge/Bash-121011?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
    <img src="https://img.shields.io/badge/Lightdash-1A73E8?style=for-the-badge&logoColor=white" alt="Lightdash">
    <img src="https://img.shields.io/badge/Tailscale-0046FF?style=for-the-badge&logo=tailscale&logoColor=white" alt="Tailscale">
</p>


## Data Pipeline

The current data pipeline operates as follows:

![Data Pipeline](images/spotify_recommendations_pipeline.png)

A Lambda function triggers an hourly script that fetches the most recent tracks I’ve listened to using the Spotify API and stores the data in an S3 bucket.

When I’m ready to update the database, I manually start an EC2 instance and run the `update_db.py` script. This script uploads the new track data from S3 to a PostgreSQL database hosted on the EC2 instance. Once the database is updated, I run dbt run to refresh the dbt-managed models. The photo below shows the dbt models that are currently implemented.

![dbt Models](images/dbt_models.png)
I will be working on automating this process. There will be a Lambda function that will trigger the EC2 instance and run the `update_db.py` script and `dbt run`. Once completed, the Lambda function will close the EC2 instance to save on costs.

## Recommendation System

Every feature is converted to a number and then scaled to a range of 0-1. This results in a dataframe with 10,000 columns and 100,000 rows which resulted in massive memory usage. To reduce the dimensionality of the data I used the TruncatedSVD to reduce the dimensionality of the columns to 100. Finally, I used cosine similarity to generate a playlist of recommended tracks based on the tracks I've listened to and those that have released in the last week.

## Other Notes

- I am using the `pgAdmin` to manage my PostgreSQL database.
- I am using the `Lightdash` to view my dbt-managed tables.
- I am using the `Tailscale` to connect to the EC2 instance from any network. Currently, my EC2 only accepts connections from my home network so to bypass this I use Tailscale to connect to the EC2 instance from any network.

## Next Steps
- Remove missing genre one hot encoded columns.
- Investigate the use of Feature Hashing for the categorical features. 
- Investigate the use of GNNs for genre and artist recommendations.

