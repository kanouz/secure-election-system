import csv
import random
import hashlib
from datetime import datetime, timedelta

NB_VOTERS = 8000
ELECTION_YEAR = 2021

first_names = [
    "Mohamed","Ahmed","Youssef","Hassan","Omar","Karim",
    "Abdelilah","Said","Rachid","Khalid",
    "Amina","Fatima","Khadija","Zineb","Salma",
    "Nadia","Imane","Sara","Hajar","Soukaina"
]

last_names = [
    "El Amrani","Benali","Alaoui","Chraibi","Kadiri",
    "Bennani","Berrada","Lahlou","Tazi","Ziani",
    "Ait Lahcen","Ait Benhaddou","El Fassi","Skalli"
]

regions = [
    "Casablanca-Settat","Rabat-Salé-Kénitra","Marrakech-Safi",
    "Fès-Meknès","Tanger-Tétouan-Al Hoceïma","Souss-Massa",
    "Oriental","Drâa-Tafilalet","Béni Mellal-Khénifra"
]

start_time = datetime(2021, 9, 8, 8, 0, 0)
end_time = datetime(2021, 9, 8, 19, 0, 0)

rows = []

for voter_id in range(1, NB_VOTERS + 1):
    first_name = random.choice(first_names)
    last_name = random.choice(last_names)
    region = random.choice(regions)
    candidate_id = random.randint(1, 4)

    vote_time = start_time + timedelta(
        seconds=random.randint(0, int((end_time - start_time).total_seconds()))
    )

    hash_input = f"{voter_id}{candidate_id}{vote_time}".encode("utf-8")
    vote_hash = hashlib.sha256(hash_input).hexdigest()

    rows.append([
        voter_id,
        first_name,
        last_name,
        region,
        ELECTION_YEAR,
        candidate_id,
        vote_time.strftime("%Y-%m-%d %H:%M:%S"),
        vote_hash
    ])

with open("online_voting_maroc_2021.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "voter_id","first_name","last_name","region",
        "election_year","candidate_id","vote_timestamp","vote_hash"
    ])
    writer.writerows(rows)

print("CSV marocain généré avec succès")

