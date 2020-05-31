//
//  GroupsViewController.swift
//  ChatRoom
//
//  Created by Rahul Goyal on 31/05/20.
//  Copyright © 2020 Rahul Goyal. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class GroupsViewController: UITableViewController {
  
  private let toolbarLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()
  
  private let channelCellIdentifier = "channelCell"
  private var currentChannelAlertController: UIAlertController?
  
  private let db = Firestore.firestore()
  
  private var channelReference: CollectionReference {
    return db.collection("channels")
  }
  
  private var groups = [Group]()
  private var channelListener: ListenerRegistration?
  private let currentUser: User
  
  deinit {
    channelListener?.remove()
  }
  
  init(currentUser: User) {
    self.currentUser = currentUser
    super.init(style: .grouped)
    title = "Group"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    clearsSelectionOnViewWillAppear = true
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
    
    toolbarItems = [
      UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(customView: toolbarLabel),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)),
    ]
    toolbarLabel.text = AppSettings.displayName
    
    channelListener = channelReference.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isToolbarHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isToolbarHidden = true
  }
    
  
  // MARK: - Actions
  @objc private func signOut() {
    let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
      do {
        try Auth.auth().signOut()
      } catch {
        print("Error signing out: \(error.localizedDescription)")
      }
    }))
    present(ac, animated: true, completion: nil)
  }
    
    
  @objc private func addButtonPressed() {
    let ac = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    ac.addTextField { field in
      field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
      field.enablesReturnKeyAutomatically = true
      field.autocapitalizationType = .words
      field.clearButtonMode = .whileEditing
      field.placeholder = "Channel name"
      field.returnKeyType = .done
      field.tintColor = .primary
    }
    
    
    let createAction = UIAlertAction(title: "Create", style: .default, handler: { _ in
      self.createChannel()
    })
    createAction.isEnabled = false
    ac.addAction(createAction)
    ac.preferredAction = createAction
    present(ac, animated: true) {
      ac.textFields?.first?.becomeFirstResponder()
    }
    currentChannelAlertController = ac
  }
  
  @objc private func textFieldDidChange(_ field: UITextField) {
    guard let ac = currentChannelAlertController else {
      return
    }
    ac.preferredAction?.isEnabled = field.hasText
  }
  
  // MARK: - Helpers
  private func createChannel() {
    guard let ac = currentChannelAlertController else {
      return
    }
    
    guard let channelName = ac.textFields?.first?.text else {
      return
    }
    
    let channel = Group(name: channelName)
    channelReference.addDocument(data: channel.representation) { error in
      if let e = error {
        print("Error saving channel: \(e.localizedDescription)")
      }
    }
  }
  
  private func addChannelToTable(_ channel: Group) {
    guard !groups.contains(channel) else {
      return
    }
    
    groups.append(channel)
    groups.sort()
    
    guard let index = groups.firstIndex(of: channel) else {
      return
    }
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  private func updateChannelInTable(_ channel: Group) {
    guard let index = groups.firstIndex(of: channel) else {
      return
    }
    
    groups[index] = channel
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  private func removeChannelFromTable(_ channel: Group) {
    guard let index = groups.firstIndex(of: channel) else {
      return
    }
    
    groups.remove(at: index)
    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    guard let channel = Group(document: change.document) else {
      return
    }
    
    switch change.type {
    case .added:
      addChannelToTable(channel)
    case .modified:
      updateChannelInTable(channel)
      
    case .removed:
      removeChannelFromTable(channel)
    }
  }
}

// MARK: - TableViewDelegate
extension GroupsViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = groups[indexPath.row].name
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let group = groups[indexPath.row]
    let vc = CustomMessagesVC(user: currentUser, group: group)
    navigationController?.pushViewController(vc, animated: true)
  }
}
