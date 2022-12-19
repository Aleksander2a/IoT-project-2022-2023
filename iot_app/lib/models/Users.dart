/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the Users type in your schema. */
@immutable
class Users extends Model {
  static const classType = const _UsersModelType();
  final String id;
  final String? _username;
  final String? _password;
  final String? _active_profile_id;
  final String? _device_id;
  final List<Profiles>? _UserProfiles;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UsersModelIdentifier get modelIdentifier {
      return UsersModelIdentifier(
        id: id
      );
  }
  
  String get username {
    try {
      return _username!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get password {
    try {
      return _password!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get active_profile_id {
    return _active_profile_id;
  }
  
  String get device_id {
    try {
      return _device_id!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<Profiles>? get UserProfiles {
    return _UserProfiles;
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Users._internal({required this.id, required username, required password, active_profile_id, required device_id, UserProfiles, createdAt, updatedAt}): _username = username, _password = password, _active_profile_id = active_profile_id, _device_id = device_id, _UserProfiles = UserProfiles, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Users({String? id, required String username, required String password, String? active_profile_id, required String device_id, List<Profiles>? UserProfiles}) {
    return Users._internal(
      id: id == null ? UUID.getUUID() : id,
      username: username,
      password: password,
      active_profile_id: active_profile_id,
      device_id: device_id,
      UserProfiles: UserProfiles != null ? List<Profiles>.unmodifiable(UserProfiles) : UserProfiles);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Users &&
      id == other.id &&
      _username == other._username &&
      _password == other._password &&
      _active_profile_id == other._active_profile_id &&
      _device_id == other._device_id &&
      DeepCollectionEquality().equals(_UserProfiles, other._UserProfiles);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Users {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("password=" + "$_password" + ", ");
    buffer.write("active_profile_id=" + "$_active_profile_id" + ", ");
    buffer.write("device_id=" + "$_device_id" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Users copyWith({String? username, String? password, String? active_profile_id, String? device_id, List<Profiles>? UserProfiles}) {
    return Users._internal(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      active_profile_id: active_profile_id ?? this.active_profile_id,
      device_id: device_id ?? this.device_id,
      UserProfiles: UserProfiles ?? this.UserProfiles);
  }
  
  Users.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _username = json['username'],
      _password = json['password'],
      _active_profile_id = json['active_profile_id'],
      _device_id = json['device_id'],
      _UserProfiles = json['UserProfiles'] is List
        ? (json['UserProfiles'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => Profiles.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'username': _username, 'password': _password, 'active_profile_id': _active_profile_id, 'device_id': _device_id, 'UserProfiles': _UserProfiles?.map((Profiles? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id, 'username': _username, 'password': _password, 'active_profile_id': _active_profile_id, 'device_id': _device_id, 'UserProfiles': _UserProfiles, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<UsersModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<UsersModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField USERNAME = QueryField(fieldName: "username");
  static final QueryField PASSWORD = QueryField(fieldName: "password");
  static final QueryField ACTIVE_PROFILE_ID = QueryField(fieldName: "active_profile_id");
  static final QueryField DEVICE_ID = QueryField(fieldName: "device_id");
  static final QueryField USERPROFILES = QueryField(
    fieldName: "UserProfiles",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Profiles).toString()));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Users";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PUBLIC,
        operations: [
          ModelOperation.CREATE,
          ModelOperation.UPDATE,
          ModelOperation.DELETE,
          ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Users.USERNAME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Users.PASSWORD,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Users.ACTIVE_PROFILE_ID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Users.DEVICE_ID,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: Users.USERPROFILES,
      isRequired: false,
      ofModelName: (Profiles).toString(),
      associatedKey: Profiles.USERSID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _UsersModelType extends ModelType<Users> {
  const _UsersModelType();
  
  @override
  Users fromJson(Map<String, dynamic> jsonData) {
    return Users.fromJson(jsonData);
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Users] in your schema.
 */
@immutable
class UsersModelIdentifier implements ModelIdentifier<Users> {
  final String id;

  /** Create an instance of UsersModelIdentifier using [id] the primary key. */
  const UsersModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'UsersModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UsersModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}