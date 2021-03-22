/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import React, { useState } from 'react';
import { StyleSheet, View, Text, TextInput } from 'react-native';
import SharedGroupPreferences from 'react-native-shared-group-preferences';

const appGroupIdentifier = 'group.YOURINFO.HERE';

const App = () => {
  const [inputText, setInputText] = useState<string>();
  const widgetData = {
    displayText: inputText,
  };

  const handleSubmit = async () => {
    try {
      await SharedGroupPreferences.setItem(
        'savedData',
        widgetData,
        appGroupIdentifier,
      );
    } catch (error) {
      console.log({ error });
    }
  };

  return (
    <View style={styles.container}>
      <Text>Enter text to display on widget:</Text>
      <TextInput
        style={styles.input}
        onChangeText={(text) => setInputText(text)}
        value={inputText}
        returnKeyType="send"
        onEndEditing={handleSubmit}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    borderRadius: 8,
    width: '100%',
    marginTop: 16,
    paddingHorizontal: 8,
  },
});

export default App;
