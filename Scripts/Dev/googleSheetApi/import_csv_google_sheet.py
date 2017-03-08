
from __future__ import print_function
import httplib2
import os

from apiclient import discovery
from oauth2client import client
from oauth2client import tools
from oauth2client.file import Storage

from datetime import datetime

import csv
from reports_merge_data import merge_data

try:
    import argparse
    flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
except ImportError:
    flags = None

# If modifying these scopes, delete your previously saved credentials
# at ~/.credentials/sheets.googleapis.com-python-quickstart.json
SCOPES = 'https://www.googleapis.com/auth/spreadsheets'
CLIENT_SECRET_FILE = 'client_secret.json'
APPLICATION_NAME = 'Google Sheets API Python Quickstart'


def get_credentials():
    """Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    credential_path = os.path.join(credential_dir,
                                   'sheets.googleapis.com-python-quickstart.json')

    store = Storage(credential_path)
    credentials = store.get()
    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
        flow.user_agent = APPLICATION_NAME
        if flags:
            credentials = tools.run_flow(flow, store, flags)
        else: # Needed only for compatibility with Python 2.6
            credentials = tools.run(flow, store)
        print('Storing credentials to ' + credential_path)
    return credentials

def main():
    """Shows basic usage of the Sheets API.

    Creates a Sheets API service object and prints the names and majors of
    students in a sample spreadsheet:
    https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
    """
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    discoveryUrl = ('https://sheets.googleapis.com/$discovery/rest?'
                    'version=v4')
    service = discovery.build('sheets', 'v4', http=http,
                              discoveryServiceUrl=discoveryUrl)

    spreadsheetId = '1y0cRvvcAZLqgvuwmplLU8rjb9d1arHHhhuTP7c0g6qM'
    #rangeName = 'Sheet1'
    rangeName = "Result "+datetime.now().strftime("%d/%m/%y")
    finalRN = "Total Results"

    body = {
            "requests": [{
                          "addSheet": {
                                       "properties": {
                                                      "title": rangeName
                                                     }
                                      }
                         }]
           }

    result = service.spreadsheets().batchUpdate(spreadsheetId=spreadsheetId, body=body).execute()

    #rowcount = 0
    with open("csv-best-configs5.csv", "r") as ins:
        values = []
        for line in ins:
           values.append(line.rstrip('\n').split(','))
           #rowcount += 1
    
    body = {
            'values': values
           }
    result = service.spreadsheets().values().update(spreadsheetId=spreadsheetId, range=rangeName,
    valueInputOption='USER_ENTERED', body=body).execute()

    body_append = {
            'values': values[1:]
           }

    result = service.spreadsheets().values().append(
    spreadsheetId=spreadsheetId, range=finalRN,
    valueInputOption='USER_ENTERED', body=body_append).execute()

    #Redirect to csv file
    result = service.spreadsheets().values().get(
        spreadsheetId=spreadsheetId, range=finalRN).execute()
    values = result.get('values', [])

    if not values:
        print('No data found.')
    else:
        #print('Name, Major:')
        csv_file = open("merge_before_results.csv","w")
        for row in values:
            #print(row)
            #print(','.join(row))
            csv_file.write(','.join(row))
            csv_file.write('\n')
        csv_file.close()

    merge_data()

    #Know the column number
    body = {
            "requests": [
                         {
                           "updateCells": {
                                           "range": {
                                                     "sheetId": 116822524
                                                    },
                                           "fields": "userEnteredValue"
                                          }
                          }
                         ]
           }
    result = service.spreadsheets().batchUpdate(spreadsheetId=spreadsheetId, body=body).execute()

    with open("merge_results.csv", "r") as ins:
        values = []
        for line in ins:
           values.append(line.rstrip('\n').split(','))
           
    #print(values)
    body = {
            'values': values
           }
    result = service.spreadsheets().values().update(spreadsheetId=spreadsheetId, range=finalRN,
    valueInputOption='USER_ENTERED', body=body).execute()

if __name__ == '__main__':
    main()

