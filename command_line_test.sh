#!/bin/sh

this_time=$(date +"%c")
red='\033[0;31m'
cyan='\033[0;36m'
orange='\033[0;33m'
yellow='\033[1;33m'
nc='\033[0m'

Take_Test()
{
	clear
        echo "~~~~~TAKE TEST~~~~~"
	echo ""
	check=/home/ec2-user/Command_Line_Test/Answers/$username.csv
	if [ -f "$check" ]
	then
		echo "You have already attempted the test."
		echo "Do you want to re-attempt the test? [Y/N]"
		read YN
		if [ "$YN" = "Y" ]
		then
			rm $check
			touch $check
		else
			View_Test
		fi
	else
		touch $check
	fi
	echo "$username started test at $this_time" >> user_logs.txt

	for i in `seq 6 6 60`
	do
		option=""
		cat test_questions.txt | head -${i} | tail -6
		echo ""
		for j in `seq 10 -1 0`
		do
			echo -e "\rTime left: ${j}s \t Select an option: \c"
			read -t 1 option
			if [ -n "${option}" ]
			then
				break
			else
				option="Unattempted"
			fi
		done
		echo ""
		echo "${option}" >> /home/ec2-user/Command_Line_Test/Answers/$username.csv
	done
	echo "$username completed test at $this_time" >> user_logs.txt
	echo "Test Completed"
	echo ""
	echo "Press ENTER to view test."
	read enter
	if [ "$enter" = "" ]
	then
		View_Test
	else
		UI
	fi

}

View_Test()
{
	clear
        echo "~~~~~VIEW YOUR TEST~~~~~"
	echo ""
	echo "$username viewed test at $this_time" >> user_logs.txt
	check=/home/ec2-user/Command_Line_Test/Answers/$username.csv
        if [ -f "$check" ]
        then
                echo "Your test results with correct answers:"
                u_ans=(`cat /home/ec2-user/Command_Line_Test/Answers/$username.csv`)
                correct=(`cat /home/ec2-user/Command_Line_Test/answers.txt`)

                for i in `seq 6 6 60`
                do
                        cat test_questions.txt | head -${i} | tail -6
                        if [ "${u_ans[$(((${i}/6)-1))]}" = "${correct[$(((${i}/6)-1))]}" ]
                        then
                                echo -e "${cyan}Your answer is correct - ${u_ans[$(((${i}/6)-1))]}${nc}"
                                echo ""
                        else
                                echo -e "${red}Your answer - ${u_ans[$(((${i}/6)-1))]}${nc}"
                                echo -e "${orange}Correct answer - ${correct[$(((${i}/6)-1))]}${nc}"
                                echo ""
                        fi
                done
	else
		echo "You've not attempted the test."
		echo ""
		echo "Choose any."
		echo "1. Take test"
		echo "2. Logout"
		echo "3. Exit"
		read choose
		case $choose in
			1) Take_Test
				;;
			2) UI
				;;
			3) exit
				;;
		esac
	fi
	echo "Choose any."
        echo "1. Re-test"
	echo "2. View score"
        echo "3. Logout"
        echo "4. Exit"
        read choose
        case $choose in
		1) rm /home/ec2-user/Command_Line_Test/Answers/$username.csv
			Take_Test
			;;
		2) Score
			;;
		3) UI
			;;
		4) exit
			;;
	esac
}

Score()
{
        clear
        echo "~~~~~YOUR SCORE~~~~~"
        echo ""
        score=0
        u_ans=(`cat /home/ec2-user/Command_Line_Test/Answers/$username.csv`)
        correct=(`cat /home/ec2-user/Command_Line_Test/answers.txt`)
        for i in `seq 0 9`
        do
                if [ "${u_ans[i]}" = "${correct[i]}" ]
                then
                        score=$((${score} + 1))
                fi
        done
        echo -e "${yellow}You scored $score out of 10.${nc}"
        echo ""
	echo "Choose any."
	echo "Enter 1 to view test:"
	echo "Enter 2 to re-attempt test:"
	echo "Enter 3 to logout:"
	echo "Enter 4 to Exit:"
	read input
	case $input in
		1) View_Test
			;;
		2) rm /home/ec2-user/Command_Line_Test/Answers/$username.csv
			Take_Test
			;;
		3) UI
			;;
		4) exit
			;;
	esac

}

Sign_In()
{
	clear
	echo "~~~~~SIGN IN HERE~~~~~"
	echo ""
        echo "Enter your Username:"
        read username
        echo "Enter your password:"
        read -s password
	if grep -q -w "$username~$password"* users.txt
	then
		echo "Login Successfully..."
		check=/home/ec2-user/command_test/User_Answer/$username.Answer.csv
		if [ -f "$check" ]
		then
			echo "Test is already attenpted."
			echo "Enter 1 to reattempt:"
			echo "Enter 2 to view results:"
			echo "Enter 3 to Exit:"
			read input
			case $input in
				1) Take_Test
					;;
				2) View_Test
					;;
				3) exit
					;;
			esac
		else
        		echo "Press 1 to take test:"
        		echo "Press 2 to view test:"
        		echo "Press 3 to Exit:"
        		read press
        		case $press in
                		1) Take_Test
                        		;;
                		2) View_Test
                        		;;
                		3) echo " $username logged out at $this_time" >> user_logs.txt
					exit
                        		;;
        		esac
		fi
	else
		echo "Inalid login credentials!"
		echo "Choose any."
		echo "1. Sign in again"
		echo "2. Sign up"
		echo "3. Exit"
		read input
		case $input in
			1) Sign_In
				;;
			2) Sign_Up
				;;
			3) exit
				;;
		esac
	fi
}

Sign_Up()
{
	clear
	echo "~~~~~SIGN UP HERE~~~~~"
	echo ""
        echo "Create username:"
	read username
	user=0
	while [ $user -ne 1 ]
	do
		if [ -z "$username" ]
		then
			echo "Username can't be blank."
		else
			if grep -q -w "$username"* users.txt
			then
				echo "Username already exist!"
			else
				if [[ "$username" =~ [^a-zA-Z0-9] ]]
				then
					echo "Username can't contain special character or space."
				else
					break
				fi
			fi
		fi
		echo "Create username:"
		read username
	done

	echo "Create password:"
        read -s password

	while [[ "$password" =~ [^a-zA-Z0-9*['!'@#\$%^\&()_+]] || -z "$password" || ${#password} -lt 8 ]]
        do
                echo "Password can't be blank and should contain atleast 8 characters. Try again."
		echo "Create password:"
                read -s password
        done

	echo "Re-enter your password:"
        read -s repassword

        while [ "$password" != "$repassword" ]
        do
		echo "Password doesn't match. Re-enter your password:"
                read -s repassword
        done
	echo "$username~$password" >> users.txt
	echo "$username signed up at $this_time" >> user_logs.txt
        echo "Signup successful."
        echo "$username is your Username."
	echo "Choose any."
	echo "1. Sign in"
	echo "2. Exit"
	read input
	case $input in
		1) Sign_In
			;;
		2) exit
			;;
	esac

}

UI()
{
	clear
	echo "~~~~~COMMAND LINE TEST~~~~~"
	echo ""
	echo "Enter 1 for Sign Up:"
	echo "Enter 2 for Sign In:"
	echo "Enter 3 for Exit:"
	read choice
	case $choice in
        	1) Sign_Up
                	;;
        	2) Sign_In
                	;;
        	3) exit
                	;;
	esac
}
UI
