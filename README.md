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
</p>


## Data Pipeline

The current data pipeline operates as follows:

![Data Pipeline](images/spotify_recommendations_pipeline.png)

A Lambda function triggers an hourly script that fetches the most recent tracks I’ve listened to using the Spotify API and stores the data in an S3 bucket.

When I’m ready to update the database, I manually start an EC2 instance and run the `update_db.py` script. This script uploads the new track data from S3 to a PostgreSQL database hosted on the EC2 instance. Once the database is updated, I run dbt run to refresh the dbt-managed tables.

## Recommendation System

Work in progress…

## Next Steps
- Create a base table for album metadata.
- Create a base table for artist metadata.
- Create a features table for albums.
- Create a features table for artists.
- Generate embedding vectors for each track using Word2Vec or a similar technique.
- Perform a nearest neighbor (NN) or approximate nearest neighbor (ANN) search to identify similar tracks—comparing tracks I’ve listened to with those I haven’t.
- Build a playlist populated with the recommended tracks.

