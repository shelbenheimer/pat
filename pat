#!/usr/bin/python3
import re, sys, socket, colorama, smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

default_server = 'smtp.gmail.com'
default_port = 587
default_timeout = 15
default_tls = True

server = default_server
port = default_port
timeout = default_timeout
tls = default_tls

root = '/usr/local/src/pat-src/'
required = ['-s', '-r', '-p', '-f']

preconfigured = {
	'Facebook': '{}Facebook/facebook.txt'.format(root)
}

structure = {
	'sender': '',
	'recipient': '',
	'password': ''
}

help_text = """P.A.T (Phishing Attack Tool) - Email client.
Before using, please enable {}2FA{} and retrieve email app password.{}
 -s | {}*{} Specify sender address.
 -r | {}*{} Specify recipient address.
 -p | {}*{} Specify sender password.
 -c | {}*{} Specify the SMTP server port.
 -f | {}*{} Specify HTML file, must be in text format.
 -t | {}*{} Specify the time it takes to stop connection attempt.
 -n | {}*{} Specify the SMTP server to use.
 -d | {}*{} Disable TLS connection.
 -l | {}*{} List all available configurations.""".format(
 	colorama.Fore.GREEN,
 	colorama.Style.RESET_ALL,
 	colorama.Fore.WHITE,
 	colorama.Fore.RED,
 	colorama.Fore.WHITE,
 	colorama.Fore.RED,
 	colorama.Fore.WHITE,
 	colorama.Fore.RED,
 	colorama.Fore.WHITE,
 	colorama.Fore.BLUE,
 	colorama.Fore.WHITE,
 	colorama.Fore.RED,
 	colorama.Fore.WHITE,
 	colorama.Fore.BLUE,
 	colorama.Fore.WHITE,
 	colorama.Fore.BLUE,
 	colorama.Fore.WHITE,
 	colorama.Fore.BLUE,
 	colorama.Fore.WHITE,
 	colorama.Fore.BLUE,
 	colorama.Fore.WHITE
)

def Response(text, colour):
	notification_type = None
	match colour:
		case 0:
			notification_type = colorama.Fore.RED
		case 1:
			notification_type = colorama.Fore.GREEN
		case 2:
			notification_type = colorama.Fore.BLUE

	print("{}[{}+{}]{} {}".format(
		colorama.Style.RESET_ALL,
		notification_type,
		colorama.Style.RESET_ALL,
		colorama.Fore.WHITE,
		text
	))
	if notification_type == 0: sys.exit()

def Help():
	print(help_text)
	sys.exit()

try:
	for argument in range(0, len(sys.argv)):
		match sys.argv[argument]:
			case '-l':
				for directory in preconfigured:
					Response("{}".format(directory), 2)
				sys.exit()

	joined = " ".join(sys.argv)
	for alias in required:
		if alias not in joined:
			Help()
			sys.exit()

	words = [""]
	content = None
	for argument in range(0, len(sys.argv)):
		match sys.argv[argument]:
			case '-s':
				structure["sender"] = sys.argv[argument + 1]
			case '-r':
				structure["recipient"] = sys.argv[argument + 1]
			case '-p':
				structure["password"] = sys.argv[argument + 1]
			case '-c':
				port = sys.argv[argument + 1]
			case '-f':
				file_directory = ""
				for directory in preconfigured:
					if sys.argv[argument + 1] == directory.lower():
						file_directory = preconfigured.get(directory)
						break
				file = open(file_directory, 'r')
				for line in file:
					words.append(line)
					content = "".join(words)
			case '-t':
				timeout = int(sys.argv[argument + 1])
			case '-n':
				server = sys.argv[argument + 1]
			case '-d':
				tls = False

	message = MIMEMultipart()
	message['From'] = structure.get('sender')
	message['To'] = structure.get('recipient')
	message['Subject'] = "Suspicious activity on your account."
	message.attach(MIMEText(content, 'html'))

	Response("Attempting connection to SMTP server.", 2)
	connection = smtplib.SMTP(server, port, None, timeout, None)
	Response("Connected to SMTP server!", 1)

	if tls: connection.starttls()

	Response("Attempting to log in.", 2)
	connection.login(structure.get('sender'), structure.get('password'))
	Response("Successfully logged in!", 1)
	
	Response("Attempting to send mail.", 2)
	connection.sendmail(structure.get('sender'), structure.get('recipient'), message.as_string())
	Response("Successfully sent mail!", 1)

	connection.quit()
except KeyboardInterrupt:
	Response("Caught keyboard interruption, exiting safely.", 0)
except AttributeError:
	Response("There was an encoding error.", 0)
except FileNotFoundError:
	Response("Failure to find the provided file.", 0)
except smtplib.SMTPRecipientsRefused:
	Response("The recipient provided was invalid.", 0)
except smtplib.SMTPAuthenticationError:
	Response("There was an error validating your session.", 0)
except TimeoutError:
	Response("Connectioned time out, please check your connection.", 0)
except IndexError:
	Response("Index out of range, please ensure the validity of provided arguments.", 0)
except ValueError:
	Response("Value error, please ensure that timeout variable is a valid number greater than zero.", 0)
except socket.gaierror:
	Response("Please ensure that port number is valid.", 0)
except smtplib.SMTPServerDisconnected:
	Response("A connection to the server could not be made, please check the SMTP server provided.", 0)
except smtplib.SMTPNotSupportedError:
	Response("Authentication failed, did you disable TLS?", 0)
