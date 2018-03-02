suffix=03-01-2018-007
size=5GB
sf_low=1
sf_high=3
iterations=200

numSnowflakeRuns=3

numParallelJobs=4
numDefaultRunsMax=4
numItersMax=90

batchSizeJobs=20

sleepWaitForJobSubmission=0.01
sleepBetweenRuns=0.01
sleepSeconds=0.01

started=`date '+%Y-%m-%d %H:%M:%S'`

i=0

echo
echo numParallelJobs = $numParallelJobs
echo numItersMax = $numItersMax
echo sleepSeconds = $sleepSeconds
echo sleepWaitForJobSubmission = $sleepWaitForJobSubmission
echo sleepBetweenRuns = $sleepBetweenRuns
echo


