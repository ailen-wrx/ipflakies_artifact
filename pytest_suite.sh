# bash pytest_suite.sh $(pwd)/projects_installed $(pwd)/Repo $(pwd)/pytest_output

projects_list=$1
repo_dir=$2
output_dir=$3

base_dir=$(pwd)
mkdir -p $output_dir
for project in `cat $projects_list`;
do
    if [[ -d $output_dir/$project ]]; then
        rm -rf $output_dir/$project
    fi
    mkdir -p $output_dir/$project
    cd $repo_dir/$project

    echo "Running pytest in" $project...
    source venv/bin/activate
    timeout 30m python -m pytest --csv $output_dir/$project/pytest.csv >> $output_dir/$project/pytest_log


    exit_status=${PIPESTATUS[0]}
    if [[ ${exit_status} -eq 124 ]] || [[ ${exit_status} -eq 137 ]]; then
	echo timeout > $output_dir/$project/timeout
    fi
    
    deactivate

    if [[ -f $output_dir/$project/pytest.csv ]]; then
	# zipping project
	echo "Zipping" $project...
	zip -rq $base_dir/Repo_zipped/$project.zip $repo_dir/$project/
    fi
	
    cd $base_dir
done
