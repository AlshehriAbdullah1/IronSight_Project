import  { useState } from "react";
import axios from "axios";


function CreateGame() {
    const [Game_Name, setGame_Name] = useState("");
    const [Game_Description, setGame_Description] = useState("");
    const [Game_Genre, setGame_Genre] = useState([]);
    const [Release_Date, setRelease_Date] = useState("");
    const [Developer, setDeveloper] = useState("");
    const [Game_Id, setGame_Id] = useState("");
    const [Game_Img_Main, setGame_Img_Main] = useState("");
    const [Game_Img_Banner, setGame_Img_Banner] = useState("");
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setGame_Id("");
        setLoading(true);
        setError("");
        setSuccess("");
        try {
            const response = await axios.post("/games", {
                Game_Name,
                Game_Description,
                Game_Genre,
                Release_Date,
                Developer,
            });
            const Game_Id = response.data;
            // console.log(Game_Id);
            setGame_Id(Game_Id);
            // Upload images
            if (Game_Id) {
                await uploadImage(Game_Img_Main, "Game_Img_Main", Game_Id);
                await uploadImage(Game_Img_Banner, "Game_Img_Banner",Game_Id);
            }
            setSuccess("Game created successfully");
        } catch (error) {
            setError(error.response.data);
        }
        setLoading(false);
    };

    const uploadImage = async (file, imageName,selectedGameId) => {
        console.log(selectedGameId);
        const formData = new FormData();
        formData.append("file", file);
        formData.append("image_name", imageName);
        formData.append("from_micro", "Game");
        formData.append("id", selectedGameId);
        formData.append("collection", "Games");
        await axios.post("/upload", formData, {
            headers: {
                "Content-Type": "multipart/form-data",
            },
        });
        setGame_Id("");
    };



    return (
        <div className="max-w-lg mx-auto bg-white shadow-md p-8 rounded-lg mt-9">
            <h2 className="text-2xl font-bold mb-4 text-center">Create Game</h2>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div className="flex flex-col">
                    <label htmlFor="game_name" className="font-semibold mb-1 text-black">Game Name:</label>
                    <input
                        id="game_name"
                        type="text"
                        value={Game_Name}
                        onChange={(e) => setGame_Name(e.target.value)}
                        className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <div className="flex flex-col">
                    <label htmlFor="game_description" className="font-semibold mb-1 text-black">Game Description:</label>
                    <textarea
                        id="game_description"
                        value={Game_Description}
                        onChange={(e) => setGame_Description(e.target.value)}
                        className="border border-gray-300 rounded-md px-3 py-2 h-32 resize-none focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <div className="flex flex-col">
                    <label htmlFor="game_genre" className="font-semibold mb-1 text-black">Game Genre:</label>
                    <input
                        id="game_genre"
                        type="text"
                        value={Game_Genre}
                        onChange={(e) => setGame_Genre(e.target.value.split(","))}
                        className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <div className="flex flex-col">
                    <label htmlFor="release_date" className="font-semibold mb-1 text-black">Release Date:</label>
                    <input
                        id="release_date"
                        type="date"
                        value={Release_Date}
                        // convert the date to a string
                        onChange={(e) => {
                            setRelease_Date(e.target.value);
                        }}
                        className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <div className="flex flex-col">
                    <label htmlFor="developer" className="font-semibold mb-1 text-black">Developer:</label>
                    <input
                        id="developer"
                        type="text"
                        value={Developer}
                        onChange={(e) => setDeveloper(e.target.value)}
                        className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <div className="flex flex-col">
                    <label htmlFor="game_img_main" className="font-semibold mb-1 text-black">Game Image (Main):</label>
                    <input
                        id="game_img_main"
                        type="file"
                        accept="image/*"
                        onChange={(e) => setGame_Img_Main(e.target.files[0])}
                        className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <div className="flex flex-col">
                    <label htmlFor="game_img_banner" className="font-semibold mb-1 text-black">Game Image (Banner):</label>
                    <input
                        id="game_img_banner"
                        type="file"
                        accept="image/*"
                        onChange={(e) => setGame_Img_Banner(e.target.files[0])}
                        className="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:border-blue-500 text-black"
                        required
                    />
                </div>
                <button type="submit" disabled={loading} className="bg-blue-500 text-white font-semibold py-2 px-4 rounded hover:bg-blue-600 focus:outline-none">
                    {loading ? "Creating..." : "Create Game"}
                </button>
                {error && <p className="text-red-500 text-sm">{error}</p>}
                {success && <p className="text-green-500 text-sm">{success}</p>}
                {Game_Id && <p>Game Id: {Game_Id}</p>}
            </form>

            <button onClick={() => window.history.back()} className="bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded inline-block mt-4 focus:outline-none">
                Go Back
            </button>
        </div>
    );


}

export default CreateGame;
