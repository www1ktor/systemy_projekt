#!/bin/bash

UTWORZ_KONTA () { 
	if [[ -z $(cat /etc/group | grep -w "studenci_informatyki") ]]; then
		groupadd studenci_informatyki
	fi

	if [[ -z $(cat /etc/group | grep -w "studenci_etyki") ]]; then
                groupadd studenci_etyki
        fi

	read -p "ile kont utworzyc? " ilosc_kont
	indeks=1
	licznik=0

	if [[ $ilosc_kont -gt 0 ]]; then
		while [[ $ilosc_kont -gt $licznik ]]; do
			if [[ -z $(cat /etc/passwd | grep -w "user$indeks") ]];then
				useradd -p password$indeks user$indeks
				licznik=$(( $licznik + 1))
				echo "utworzono user$indeks, utworzonych kont: $licznik z $ilosc_kont"
				
				if [[ $licznik -le $(( $ilosc_kont / 2 )) ]]; then
					usermod -aG studenci_informatyki user$indeks
					echo "dodano uzytkownika user$indeks do grupy studenci_informatyki"
				else
					usermod -aG studenci_etyki user$indeks
					echo "dodano uzytkownika user$indeks do grupy studenci_etyki"
				fi

				indeks=$(( $indeks + 1 ))
			else
				indeks=$(( $indeks + 1 ))
			fi	
		done
	else
		echo "podano bledna ilosc kont!"
		exit 1
	fi

	exit 0
}


WYSWIETL_KONTA () {
	cat /etc/passwd | awk -F ':' '{print $1}'
	exit 0
}


WYSWIETL_GRUPY () { 
	cat /etc/group | awk -F ':' '{print $1}'
	exit 0
}

WYSWIETL_ZAWARTOSC_GRUP ()  {
	(echo "nazwa_grupy::id_grupy:czlonkowie_grupy"; cat /etc/group) | awk -F ':' '{print $1":"$3":"$4}' | csvlook --delimiter=":"
	exit 0
}

while [[ true ]]; do
	echo "1. utworz X kont"
	echo "2. wyswietl konta"
	echo "3. wyswietl grupy"
	echo "4. wyswietl zawartosc grup"
	echo "0. wyjscie do menu glownego"

	read -p "twoj wybor: " wybor
	clear

	if [[ "$wybor" == "0" ]]; then
		clear
		break
	fi

	case $wybor in 
		1)
			UTWORZ_KONTA;;
		2)
			WYSWIETL_KONTA;;
		3)
			WYSWIETL_GRUPY;;
		4)
			WYSWIETL_ZAWARTOSC_GRUP;;
		*)
			clear
			echo "Brak opcji $wybor w menu. Spróbuj jeszcze raz!"
	esac		
done

exit 0
