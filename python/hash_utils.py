import hashlib
from datetime import datetime

def generate_vote_hash(voter_id: int, candidate_id: int, vote_time: datetime) -> str:
	 hash_input = f"{voter_id}:{candidate_id}:{vote_time.strftime('%Y%m%d%H%M%S')}".encode("utf-8")
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
    ])return hashlib.sha256(hash_input).hexdigest()
