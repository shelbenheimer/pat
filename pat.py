#!/usr/bin/python3
# All software written by Tomas. (https://github.com/shelbenheimer/ata-shell)

import os
import sys
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

DEFAULT_SERVER = 'smtp.gmail.com'
DEFAULT_PORT = 587
DEFAULT_TIMEOUT = 15
DEFAULT_TLS = True

REQUIRED = [ '-s', '-r', '-p', '-t', '-f' ]

class Post:
	def __init__(self, server, port, timeout, tls):
		self.server = server
		self.port = port
		self.timeout = timeout
		self.tls = tls

		self.connection = None
		self.subject = None
		self.sender = None
		self.recipient = None
		self.password = None
		self.content = None

	def ParseArgs(self, args):
		for arg in range(0, len(args)):
			match args[arg]:
				case '-s':
					self.sender = args[arg + 1]
				case '-r':
					self.recipient = args[arg + 1]
				case '-p':
					self.password = args[arg + 1]
				case '-t':
					self.subject = args[arg + 1]
				case '-f':
					self.content = self.ParseHTML(args[arg + 1])

	def ParseHTML(self, path):
		if not os.path.exists(path):
			print("Path to file not found.")
			sys.exit()

		buffer = []
		with open(path, 'r', encoding="utf8") as file:
			for line in file:
				buffer.append(line)
			return "".join(buffer)
		return ""

	def ConstructMail(self):
		message = MIMEMultipart()
		message['From'] = self.sender
		message['To'] = self.recipient
		message['Subject'] = self.subject
		message.attach(MIMEText(self.content, 'html'))

		return message.as_string()

	def EstablishConnection(self):
		self.connection = smtplib.SMTP(self.server, self.port, None, self.timeout, None)

		if self.tls: self.connection.starttls()

		self.connection.login(self.sender, self.password)

	def SendMail(self, mail):
		if not self.connection: return

		self.connection.sendmail(self.sender, self.recipient, mail)
		self.connection.quit()

def CheckRequired(args, required):
	for arg in required:
		if arg not in args: return False
	return True

try:
	post = Post(DEFAULT_SERVER, DEFAULT_PORT, DEFAULT_TIMEOUT, DEFAULT_TLS)

	if not CheckRequired(sys.argv, REQUIRED):
		print("Flag criteria not met.")
		sys.exit()

	post.ParseArgs(sys.argv)
	post.EstablishConnection()

	mail = post.ConstructMail()
	post.SendMail(mail)
except KeyboardInterrupt:
	print("Caught interruption. Exiting gracefully.")