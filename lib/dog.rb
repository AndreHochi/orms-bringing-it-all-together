class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.new_from_db(row)
        self.new({id: row[0], name: row[1], breed: row[2]})
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        new_dog = self.new(hash)
        new_dog.save
    end

    def self.find_by_id(id)
        results = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
        self.new({id: results[0][0], name: results[0][1], breed: results[0][2]})
    end

    def self.find_by_name(name)
        results = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        self.new({id: results[0][0], name: results[0][1], breed: results[0][2]})
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
    end

    def self.find_or_create_by(name:, breed:)
        results = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !results.empty?
            return_results = self.new({id: results[0][0], name: results[0][1], breed: results[0][2]})
        else
            return_results = self.create({name: name, breed: breed})
        end
    end

end