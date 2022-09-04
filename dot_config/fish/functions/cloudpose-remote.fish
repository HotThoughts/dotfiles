function cloudpose-remote

  gcloud compute config-ssh --remove
  gcloud beta compute ssh --zone "us-central1-a" "cloudpose"  --project "advance-rush-261711"
  gcloud compute config-ssh
end
